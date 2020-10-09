# Translator
Переводчик с основных европейских языков на базе Yandex Translate.

<img src="Screenshots/Screenshot%201.jpg" width="300">, <img src="Screenshots/Screenshot%202.jpg" width="300">, <img src="Screenshots/Screenshot%203.jpg" width="300">

## Технологии
- Верстка в коде (без Storyboards), SnapKit
- Новые iOS 14 API: Collection View Compositional List Layout и Cell Registration
- Collection View Diffable Data Sources
- Swift/RxSwift
- Работа с сетью: Moya/RxMoya
- Хранение данных: Realm
- Natural Language API для определения языков

## Требования
- iOS 14 и выше, Xcode 12

## Как запустить
- Для работы с Yandex Translate необходимо зарегистрироваться на Yandex.Cloud и создать API-ключ. Инструкция по созданию API-ключа: https://cloud.yandex.ru/docs/iam/operations/api-key/create
- После получения API-ключа запустить Translator.**xcworkspace**, далее Translator->Translator->Service->YandexService и вставить API-ключ в свойство API_KEY
- При необходимости, в Project Navigator выбрать Translator, перейти в Signing & Capabilites, в поле Team выбрать необходимый Team, Bundle Identifier изменить на любой другой
