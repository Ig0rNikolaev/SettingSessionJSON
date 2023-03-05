import Foundation

struct Cards: Decodable {
    let cards: [Card]
}

struct Card: Decodable {
    let name: String?
    let manaCost: String?
    let cmc: Int?
    let type: String?
    let rarity: String?
    let set: String?
    let setName: String?
    let artist: String?
}

class CreatureURL {
    func buildURL(scheme: String, host: String, path: String, value: String?) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [URLQueryItem(name: "name", value: value)]
        return components.url
    }
}

class RequestJSON {
    enum NetworkError: String, Error {
        case badRequest = "Плохой запрос: Мы не смогли обработать это действие"
        case forbidden = "Запрещено: Вы превысили лимит скорости"
        case notFound = "Не найдено: Запрошенный ресурс не найден"
        case internalServerError = "Ошибка сервера: У нас была проблема с нашим сервером. Пожалуйста, повторите попытку позже."
        case serviceUnavailable = "Сервис недоступен: Мы временно не в сети для технического обслуживания. Пожалуйста, повторите попытку позже"
    }

    func printCardInfo(_ cardsJSON: Cards) {
        cardsJSON.cards.forEach() {
            if $0.name == "Ornithopter" || $0.name == "Black Lotus" {
                let cardPrint = """
                        DATA |JSON| \($0.type ?? " "): -------------->\n
                        |  Имя карты:                        |  \($0.name ?? " ")
                        |  Стоимость маны:                   |  \($0.manaCost ?? " ")
                        |  Конвертированная стоимость маны:  |  \($0.cmc ?? 0)
                        |  Редкость карты:                   |  \($0.rarity ?? " ")
                        |  Набор к картe (заданный код):     |  \($0.set ?? " ")
                        |  Набор к карте:                    |  \($0.setName ?? " ")
                        |  Исполнитель:                      |  \($0.artist ?? " ")\n
                        """
                print(cardPrint)
            }
        }
    }

    func getData(urlRequest: URL?) {
        guard let url = urlRequest else { return }
        print("Ожидание ответа с сервера..\n")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                print("Ошибка при запросе: \(String(describing: error?.localizedDescription))")
            }
            guard let response = response as? HTTPURLResponse else {
                print("Ошибка при запросе: \(String(describing: error?.localizedDescription))")
                return }

            switch response.statusCode {
            case 100...103:
                print("Информационный код: \(response.statusCode)")
            case 200...299:
                do {
                    guard let data = data else {
                        print("Ошибка запроса данных")
                        return
                    }
                    let cards = try JSONDecoder().decode(Cards.self, from: data)
                    self.printCardInfo(cards)
                } catch {
                    print("Ошибка при запросе: \(String(describing: error.localizedDescription))")
                }
            case 300...399:
                print("Сообщение о перенаправлении: \(response.statusCode)")
            case 400:
                print("\(NetworkError.badRequest.rawValue). Ошибка: \(response.statusCode)")
            case 403:
                print("\(NetworkError.forbidden.rawValue). Ошибка: \(response.statusCode)")
            case 404:
                print("\(NetworkError.notFound.rawValue). Ошибка: \(response.statusCode)")
            case 500:
                print("\(NetworkError.internalServerError.rawValue). Ошибка: \(response.statusCode)")
            case 503:
                print("\(NetworkError.serviceUnavailable.rawValue). Ошибка: \(response.statusCode)")
            default:
                break
            }
        }.resume()
    }
}

let сreatureURL = CreatureURL()
let requestJSON = RequestJSON()
let url = сreatureURL.buildURL(scheme: "https",
                               host: "api.magicthegathering.io",
                               path: "/v1/cards",
                               value: "Black+Lotus|Ornithopter")
requestJSON.getData(urlRequest: url)

extension String {
    static func | (lhs: String, rhs: String) -> String {
        return lhs + "|" + rhs
    }
}
