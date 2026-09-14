# Decision Matrix — выбор технологии без догм

## SwiftUI vs UIKit
**SwiftUI:** новые feature/screens, декларативный state-driven UI, быстрые итерации, cross-platform UI where appropriate.  
**UIKit:** глубокий legacy integration, зрелые custom components/transitions/layouts, специфический lifecycle/control, постепенная миграция.  
**Hybrid:** нормальный вариант. Граница должна иметь ясный lifecycle и ownership.

## Observation vs ObservableObject
Используй Observation для современного SwiftUI data flow при подходящей availability. Сохраняй ObservableObject, если deployment target/legacy/Combine integration делает миграцию неоправданной.

## SwiftData vs Core Data
SwiftData — более декларативная модель для современных проектов. Core Data — зрелый выбор для сложных existing stores, migration history, advanced modeling и долгоживущих приложений. Не мигрируй ради синтаксиса.

## URLSession vs third-party networking
URLSession + Codable/typed endpoint layer достаточно для большинства приложений. Third-party библиотека оправдана, если реально сокращает сложность (например, сложные middleware/serialization/pinning policies) и проходит dependency audit.

## Async/await vs Combine
Async/await — default для request/response и последовательных async workflows. AsyncSequence — для потоков. Combine сохраняй при уже существующих reactive pipelines, сложном operators graph или API, где он естественен.

## Actor vs lock vs MainActor
Actor — default для изолированного mutable state. MainActor — только state, действительно принадлежащий UI/main executor. Lock/atomic — для очень низкоуровневых/performance-sensitive синхронных участков после измерения и с чётким инвариантом.

## SPM modularization
Модуль создавай для ownership/build isolation/reuse/test boundaries, а не для каждого экрана. Следи за графом зависимостей и временем сборки.

## Protocol abstraction
Вводи protocol на границе изменчивой зависимости или когда нужен test seam/polymorphism. Не создавай protocol для каждого concrete type автоматически.
