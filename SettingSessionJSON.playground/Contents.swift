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
            print("Не найдено: 404. Запрошенный ресурс не найден")
            return
        }
        let cardPrint = """
            Имя карты: \(card.name ?? " ")
            Стоимость маны: \(card.manaCost ?? " ")
            Конвертированная стоимость маны: \(card.cmc ?? 0)
            Тип карты: \(card.type ?? " ")
            Редкость карты: \(card.rarity ?? " ")
            Набор, к которому принадлежит карта (заданный код): \(card.set ?? " ")
            Набор, к которому принадлежит карта: \(card.setName ?? " ")
            Исполнитель: \(card.artist ?? " ")
            """
        print(cardPrint)
    }

    func getData(urlRequest: URL?) {
        guard let url = urlRequest else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                print("Ошибка при запросе: \(String(describing: error?.localizedDescription))")
            }

            guard let response = response as? HTTPURLResponse else { return }

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
                print("\(Errors.badRequest). Ошибка: \(response.statusCode)")
            case 403:
                print("\(Errors.forbidden). Ошибка: \(response.statusCode)")
            case 404:
                print("\(Errors.notFound). Ошибка: \(response.statusCode)")
            case 500:
                print("\(Errors.internalServerError). Ошибка: \(response.statusCode)")
            case 503:
                print("\(Errors.serviceUnavailable). Ошибка: \(response.statusCode)")
            default:
                break
            }
        }.resume()
    }
}

let сreatureURL = CreatureURL()
let requestJSON = RequestJSON()

let urlLotus = сreatureURL.buildURL(scheme: "https", host: "api.magicthegathering.io", path: "/v1/cards", value: "Black+Lotus")
let urlOpt = сreatureURL.buildURL(scheme: "https", host: "api.magicthegathering.io", path: "/v1/cards", value: "Opt")

requestJSON.getData(urlRequest: urlLotus)
requestJSON.getData(urlRequest: urlOpt)






