
struct Coordinate: Decodable, Encodable {
    let lat: Double
    let lng: Double
    init(lat: Double, lng: Double) {
        self.lat = lat;
        self.lng = lng;
    }
}
