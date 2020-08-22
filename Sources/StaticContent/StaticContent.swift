import Foundation
import Yams
import Ink

public struct StaticContentItem: Codable {
    public var meta: [String: String]
    public var entry: String
}

public struct StaticContent {
    var directory: String = ""
    var orderBy: String = ""
    var order: String = ""
    var fileExtension: String = "md"

    init(directory: String, orderBy: String = "", order: String = "", fileExtension: String = "") {
        // Set the directory we'll be getting the content from.
        // We'll also add a trailing slash in case the user forgot to add one.
        if(directory.suffix(1) != "/") {
            self.directory = directory + "/"
        } else {
            self.directory = directory
        }
        
        // Meta key by which to order the content.
        if orderBy != "" {
            self.orderBy = orderBy
        }
        
        // Direction by which to order the content (asc, desc)
        if order != "" {
            self.order = order
        }
        
        // Overwrite the default file extension (md)
        if fileExtension != "" {
            self.fileExtension = fileExtension
        }
    }
    
    /**
     * Get all the files from `self.directory` or return an empty array if no files were found.
     */
    private func getFiles() -> [String] {
        let fileManager = FileManager()
        let files = try? fileManager.contentsOfDirectory(atPath: self.directory)
        var markdownFiles: [String] = []

        if files != nil {
            for filename in files! {
              if filename.hasSuffix(".md") {
                markdownFiles.append(filename)
              }
            }
        }

        return markdownFiles
    }
    
    /**
     * Parses the files found with `getFiles()` and turns them into actual content.
     */
    private func parseFiles(files: [String]) -> [StaticContentItem] {
        var items: [StaticContentItem] = []
        
        for file in files {
            let fileContent = try? String(contentsOfFile: self.directory + file, encoding: String.Encoding.utf8)
            
            if fileContent != nil {
                // Let's get the YAML data with a little help of regex and Yams
                if let yamlRange = fileContent!.range(of: "(?s)(?<=---\n).*(?=\n---)", options: .regularExpression) {
                    let yamlRangeResult = String(fileContent![yamlRange])
                    let yamlData = try? Yams.load(yaml: yamlRangeResult) as? [String: Any] ?? [:]
                    
                    // Let's get the entry, and parse it as markdown
                    // TODO: add markdown parsing as an optional thing
                    if let contentRange = fileContent!.range(of: "(?s)(?<=\n---).*", options: .regularExpression) {
                        let parser = MarkdownParser()
                        let contentRangeResult = String(fileContent![contentRange])
                        let contentEntry = parser.html(from: contentRangeResult)
                        
                        // Construct metadata
                        var metadata: [String: String] = [:]
                        
                        if yamlData != nil {
                            for yamlDataItem in yamlData! {
                                if yamlDataItem.key == "date" {
                                    let date = yamlDataItem.value as? Date
                                    
                                    if date != nil {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        metadata[yamlDataItem.key] = dateFormatter.string(from: date!)
                                        
                                        let relativeDateFormatter = RelativeDateTimeFormatter()
                                        relativeDateFormatter.unitsStyle = .full
                                        metadata["relativeDate"] = relativeDateFormatter.localizedString(for: date!, relativeTo: Date())
                                    }
                                } else {
                                    metadata[yamlDataItem.key] = yamlDataItem.value as? String
                                }
                            }
                        }
                        
                        // Let's add this juicy result to `items`
                        items.append(StaticContentItem.init(meta: metadata, entry: contentEntry))
                    }
                }
            }
        }
        
        return items
    }
    
    /**
     * Sorts content by meta key, in descending order.
     */
    private func sortContentByKeyDesc(key: String, files: [StaticContentItem]) -> [StaticContentItem] {
        return files.sorted(by: { (x, y) in
            return x.meta[key] ?? "" > y.meta[key] ?? ""
        })
    }
    
    /**
     * Sorts content by meta key, in ascending order.
     */
    private func sortContentByKeyAsc(key: String, files: [StaticContentItem]) -> [StaticContentItem] {
        return files.sorted(by: { (x, y) in
            return x.meta[key] ?? "" < y.meta[key] ?? ""
        })
    }
    
    /**
     * Get all items from the `self.directory`, potentially in a sorted fashion.
     */
    public func getAll() -> [StaticContentItem] {
        let files = self.getFiles()
        let parsedFiles = self.parseFiles(files: files)
        
        if self.orderBy != "" {
          var order = "desc"

          if self.order != "" {
            order = self.order
          }

          if order == "desc" {
            return self.sortContentByKeyDesc(key: self.orderBy, files: parsedFiles)
          } else {
            return self.sortContentByKeyAsc(key: self.orderBy, files: parsedFiles)
          }
        }
        
        return parsedFiles
    }
    
    /**
     * Get one item from `self.directory`, according to a key-value pair that matches.
     */
    public func get(key: String, value: String) -> StaticContentItem? {
        let files = self.getFiles()
        let parsedFiles = self.parseFiles(files: files)
        
        for parsedFile in parsedFiles {
            if parsedFile.meta[key] != nil && parsedFile.meta[key] == value {
                return parsedFile
            }
        }
        
        return nil
    }
}
