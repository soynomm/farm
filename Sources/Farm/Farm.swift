import Foundation
import Yams
import Ink

public struct FarmItem: Codable {
    public var meta: [String: String]
    public var entry: String
}

public struct Farm {
    var directory: String = ""
    var orderBy: String = ""
    var order: String = ""
    var fileExtension: String = "md"

    public init(directory: String, orderBy: String = "", order: String = "", fileExtension: String = "") {
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
    private func parseFiles(files: [String]) -> [FarmItem] {
        var items: [FarmItem] = []
        
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
                                        metadata["relativeDate"] = relativeTime(date!)
                                    }
                                } else {
                                    metadata[yamlDataItem.key] = yamlDataItem.value as? String
                                }
                            }
                        }
                        
                        // Let's add this juicy result to `items`
                        items.append(FarmItem.init(meta: metadata, entry: contentEntry))
                    }
                }
            }
        }
        
        return items
    }
    
    private func relativeTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
        
        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        }
        
        if let year = components.year, year >= 1 {
            return "Last year"
        }
        
        if let month = components.month, month >= 2 {
            return "\(month) months ago"
        }
        
        if let month = components.month, month >= 1 {
            return "Last month"
        }
        
        if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return "Last week"
        }
        
        if let day = components.day, day >= 2 {
            return "\(day) days ago"
        }
        
        if let day = components.day, day >= 1 {
            return "Yesterday"
        }
        
        if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return "An hour ago"
        }
        
        if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "A minute ago"
        }
        
        if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        }
        
        return "Just now"
    }
    
    /**
     * Sorts content by meta key, in descending order.
     */
    private func sortContentByKeyDesc(key: String, files: [FarmItem]) -> [FarmItem] {
        return files.sorted(by: { (x, y) in
            return x.meta[key] ?? "" > y.meta[key] ?? ""
        })
    }
    
    /**
     * Sorts content by meta key, in ascending order.
     */
    private func sortContentByKeyAsc(key: String, files: [FarmItem]) -> [FarmItem] {
        return files.sorted(by: { (x, y) in
            return x.meta[key] ?? "" < y.meta[key] ?? ""
        })
    }
    
    /**
     * Get all items from the `self.directory`, potentially in a sorted fashion.
     */
    public func getAll() -> [FarmItem] {
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
    public func get(key: String, value: String) -> FarmItem? {
        let files = self.getFiles()
        let parsedFiles = self.parseFiles(files: files)
        
        return parsedFiles.filter {
            $0.meta[key] != nil && $0.meta[key] == value
        }[0]
    }
}
