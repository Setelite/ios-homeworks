import Foundation

enum FeedGenre: String, CaseIterable {
    case humor
    case animals
    case cinema
    case travel

    var title: String {
        switch self {
        case .humor: return L10n.tr("home.genre.humor")
        case .animals: return L10n.tr("home.genre.animals")
        case .cinema: return L10n.tr("home.genre.cinema")
        case .travel: return L10n.tr("home.genre.travel")
        }
    }

    var catAPICategoryID: Int? {
        switch self {
        case .humor: return 4
        case .animals: return 5
        case .cinema: return 1
        case .travel: return 7
        }
    }

    var authorTitles: [String] {
        switch self {
        case .humor:
            return ["Котокомедия", "Мур-юмор", "Смешной хвост"]
        case .animals:
            return ["Лапки дня", "Кото-друзья", "Пушистая лента"]
        case .cinema:
            return ["Кото-кино", "Мур-премьера", "Кинокот"]
        case .travel:
            return ["Котопутешествия", "Лапы в пути", "Хвостатый турист"]
        }
    }

    var captionPrefix: String {
        switch self {
        case .humor:
            return "Настроение: кото-юмор."
        case .animals:
            return "Настроение: спокойные пушистики."
        case .cinema:
            return "Настроение: кадр как из фильма."
        case .travel:
            return "Настроение: путешествие с хвостом."
        }
    }

    var russianCaptions: [String] {
        switch self {
        case .humor:
            return [
                "Когда пришел в зал на 30 минут, а остался на два часа.",
                "План на день: быть серьезным. Реальность: мемы и кофе.",
                "Настроение: продуктивность после третьего напоминания.",
                "Рабочий чат молчит — значит, все уже в дедлайне.",
                "Сегодня без драмы: только юмор и хорошие новости."
            ]
        case .animals:
            return [
                "Этот взгляд лучше любого утреннего будильника.",
                "Пушистый контролер качества проверил контент.",
                "Когда кот решил, что он главный редактор ленты.",
                "Уровень мотивации: как у собаки перед прогулкой.",
                "Самый позитивный пост дня официально найден."
            ]
        case .cinema:
            return [
                "Кадр дня: как будто сцена из комедии.",
                "Если бы этот момент был фильмом, это был бы хит.",
                "Сюжетный поворот, который никто не ожидал.",
                "Ставим лайк за отличную постановку кадра.",
                "Кинонастроение включено: попкорн не обязателен."
            ]
        case .travel:
            return [
                "Путешествие началось с плана и закончилось приключением.",
                "Лучшие маршруты — те, где есть место спонтанности.",
                "Открытка дня: красиво, легко и с улыбкой.",
                "Этот вид точно стоил раннего подъема.",
                "Немного дороги, немного юмора и много впечатлений."
            ]
        }
    }
}

protocol FeedGenreConfigurable: AnyObject {
    func setGenre(_ genre: FeedGenre)
}
