import Foundation

enum SortOption {
    case title
    case author
    case published
}

enum SortOrder {
    case ascending
    case descending
}

enum ToolbarMode {
    case standardMode
    case editMode
}

enum Field: Hashable {
    case title
    case author
    case genre
    case series
    case isbn
    case publisher
    case published
}
