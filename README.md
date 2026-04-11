# Navigation iOS App

## О проекте
`Navigation` — учебное приложение в стиле VK на `UIKit` с полностью кодовой версткой (`Auto Layout`, без storyboard для экранов), поддержкой `iPhone/iPad`, темной темы и модульной навигации через `Coordinator`.

## Что реализовано
- Авторизация через Firebase (REST API Identity Toolkit) + сохранение сессии.
- Отображение данных пользователя в профиле (имя, статус, аватар, редактирование и сохранение).
- VK-подобный `TabBar`: Главная, Поиск, Чаты, Клипы, Меню.
- Лента, сторис, взаимодействие с постами (лайк/комментарий/репост), создание и редактирование пользовательских публикаций.
- Экран `Поиск` с API-данными:
  - База знаменитостей и мини-портфолио (`TVMaze API`).
  - База музыки для бесплатного прослушивания (`iTunes Search API`) + встроенный плеер превью.
- Клипы с онлайн-стримингом.
- Локальные уведомления с категорией `updates` и кастомным действием.
- Локализация `ru/en` и централизованный `StyleGuide` (цвета/шрифты).

## Архитектура
- `Coordinator` для навигации: `AppCoordinator`, `TabBarCoordinator`, feature-координаторы.
- `MVVM` для экранов с бизнес-логикой (`Login`, `Feed`, `Search`, `Profile`).
- `Services` для инфраструктуры и данных:
  - `Services/API/*` — внешние API.
  - `Services/Firebase/*` — Firebase auth + сессия.
  - `Services/CoreData/*` — избранное.

> Legacy-след из ДЗ (`FeedModel`) удален: проверка слова перенесена в сервис `WordValidationService` внутри MVVM-потока.

## Технологии и зависимости
- `Swift`, `UIKit`, `Auto Layout`
- `SPM`:
  - `SnapKit`
  - `Firebase iOS SDK`
  - `KeychainAccess`
  - `iOSIntPackage`

## Скриншоты
- Лента: `docs/screenshots/home-feed.jpg`
- Профиль: `docs/screenshots/profile.jpg`
- Поиск/музыка: `docs/screenshots/search-music.jpg`

## Сборка
```bash
xcodebuild -project Navigation.xcodeproj -scheme Navigation -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

## Тесты
```bash
xcodebuild -project Navigation.xcodeproj -scheme Navigation -only-testing:NavigationTests test
```
