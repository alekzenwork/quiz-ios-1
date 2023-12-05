struct Actor: Codable {
    let name: String
    let asCharacter: String
}
struct Movie: Codable {
    let title: String
    let year: Int
    let releaseDate: String
    let runtimeMins: Int
    let directors: String
    let actorList: [Actor]

    enum ParseError: Error {
        case yearFailure
        case runtimeMinsFailure
    }
    
    enum CodingKeys: CodingKey {
        case title, year, releaseDate, runtimeMins, directors, actorList
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)

        let year = try container.decode(String.self, forKey: .year)
        guard let yearValue = Int(year) else {
            throw ParseError.yearFailure
        }
        self.year = yearValue

        releaseDate = try container.decode(String.self, forKey: .releaseDate)

        let runtimeMins = try container.decode(String.self, forKey: .runtimeMins)
        guard let runtimeMinsValue = Int(runtimeMins) else {
            throw ParseError.runtimeMinsFailure
        }
        self.runtimeMins = runtimeMinsValue

        directors = try container.decode(String.self, forKey: .directors)
        actorList = try container.decode([Actor].self, forKey: .actorList)
    }
}
