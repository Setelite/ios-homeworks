# Navigation iOS App

## О проекте
`Navigation` — учебное iOS-приложение на `UIKit` с экраном ленты, профиля, избранного, настройками и авторизацией.

## Основной функционал
- Авторизация и базовая навигация по вкладкам.
- Работа с лентой постов и деталями.
- Экран профиля и фото.
- Избранное и настройки.
- Локальные уведомления с категорией `updates` и пользовательским действием.

## Технологии
- `Swift`
- `UIKit`
- `Auto Layout` (верстка в коде, без storyboard для экранов)
- `SPM` зависимости:
  - `SnapKit`
  - `Firebase iOS SDK`
  - `KeychainAccess`
  - `iOSIntPackage`

## Архитектура
В проекте используется модульный подход вокруг `Coordinator`-навигации.

Основные принципы:
- Навигация: `Coordinator` (`AppCoordinator`, `LoginCoordinator`, `TabBarCoordinator`).
- Экраны: `UIViewController` + выделенные сервисы.
- Сервисы: отдельные сущности в `Navigation/Services`.
- Зависимости между модулями передаются явно через инициализаторы/координаторы.

## Стайлгайд
Базовый стайлгайд вынесен в единое место:
- `Navigation/StyleGuide.swift`

В нем определены:
- Цвета (`StyleGuide.Colors`)
- Шрифты (`StyleGuide.Fonts`)

## iPad и адаптивность
- В целевых настройках включена поддержка iPhone + iPad (`TARGETED_DEVICE_FAMILY = 1,2`).
- Интерфейс построен на `Auto Layout`, что позволяет адаптироваться под разные размеры экранов.

## Сборка
```bash
xcodebuild -scheme Navigation -configuration Debug -destination 'generic/platform=iOS Simulator' build
```

## Структура проекта
- `Navigation/` — основной код приложения
- `NavigationTests/` — unit tests
- `StorageService/` — отдельный фреймворк сервиса хранения

## Планы по улучшению
- Полный перевод всех UI-цветов и шрифтов на `StyleGuide`.
- Ужесточение единых правил архитектуры по всем модулям.
- Расширение покрытия тестами сервисов и view-моделей.
