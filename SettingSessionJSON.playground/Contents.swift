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

    func buildURL(scheme: String, host: String, path: String, value: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [URLQueryItem(name: "name", value: value)]
        return components.url
    }
}

class RequestJSON {

    enum Errors: String, Error {
        case badRequest = "Плохой запрос: Мы не смогли обработать это действие"
        case forbidden = "Запрещено: Вы превысили лимит скорости"
        case notFound = "Не найдено: Запрошенный ресурс не найден"
        case internalServerError = "Ошибка сервера: У нас была проблема с нашим сервером. Пожалуйста, повторите попытку позже."
        case serviceUnavailable = "Сервис недоступен: Мы временно не в сети для технического обслуживания. Пожалуйста, повторите попытку позже"
    }

    func printCardInfo(_ cards: Cards) {
        guard let card = cards.cards.first else {
            print(Errors.notFound.rawValue)
            return
        }
        let cardPrint = """
            Данные JSON:\n
            Имя карты: \(card.name ?? " ")
            Стоимость маны: \(card.manaCost ?? " ")
            Конвертированная стоимость маны: \(card.cmc ?? 0)
            Тип карты: \(card.type ?? " ")
            Редкость карты: \(card.rarity ?? " ")
            Набор к картe (заданный код): \(card.set ?? " ")
            Набор к карте: \(card.setName ?? " ")
            Исполнитель: \(card.artist ?? " ")\n
            """
        print(cardPrint)
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
                    guard let data = data else { return }
                    let cards = try JSONDecoder().decode(Cards.self, from: data)
                    self.printCardInfo(cards)
                } catch {
                    print("Ошибка при запросе: \(String(describing: error.localizedDescription))")
                }
            case 300...399:
                print("Сообщение о перенаправлении: \(response.statusCode)")
            case 400:
                print("\(Errors.badRequest.rawValue). Ошибка: \(response.statusCode)")
            case 403:
                print("\(Errors.forbidden.rawValue). Ошибка: \(response.statusCode)")
            case 404:
                print("\(Errors.notFound.rawValue). Ошибка: \(response.statusCode)")
            case 500:
                print("\(Errors.internalServerError.rawValue). Ошибка: \(response.statusCode)")
            case 503:
                print("\(Errors.serviceUnavailable.rawValue). Ошибка: \(response.statusCode)")
            default:
                break
            }
        }.resume()
    }
}

let сreatureURL = CreatureURL()
let requestJSON = RequestJSON()

let urlOpt = сreatureURL.buildURL(scheme: "https", host: "api.magicthegathering.io", path: "/v1/cards", value: "Opt")
requestJSON.getData(urlRequest: urlOpt)

let urlLotus = сreatureURL.buildURL(scheme: "https", host: "api.magicthegathering.io", path: "/v1/cards", value: "Black+Lotus")
requestJSON.getData(urlRequest: urlLotus)

