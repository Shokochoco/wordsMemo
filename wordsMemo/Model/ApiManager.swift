import Foundation
import Alamofire

protocol apiDelegate: AnyObject {
    func jsonData(_ newsInfo: NewsData)
}

struct ApiManager {

    weak var delegate: apiDelegate?

    func performRequest() {
        guard let newsURL = URL(string: "https://newsapi.org/v2/top-headlines?country=fr&apiKey=6b52721a8f3646f3915d33c06a28157a") else { return }
        let request = AF.request(newsURL)
        request.responseJSON { response in
            guard let data = response.data else { return }
            if let safeData = self.parseJSON(data) {
                delegate?.jsonData(safeData)
            }
            print("error")
        }
    }

    func parseJSON(_ newsData: Data) -> NewsData? {

        let decoder = JSONDecoder()

        do {
            let newsInfo = try decoder.decode(NewsData.self, from: newsData)
            return newsInfo
        } catch  {
            print("パースに失敗しました")
            return nil
        }
    }

}
