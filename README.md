# tech-school-navigator-app
🏫 Tech School Navigator  
Курсовой проект "Разработка мобильного приложения для навигации и предоставления сервисной информации в учебном заведении"  
# Описание  
Мобильное приложение для студентов, преподавателей и посетителей учебного заведения. Упрощает навигацию по кампусу и предоставляет актуальную сервисную информацию в удобном формате.  

# ✨ Возможности
- Интерактивная карта кампуса с поиском зданий и аудиторий
- Построение маршрутов между любыми точками
- Просмотр новостей техникума
- Регистрация пользователей
- Админ панель

🛠️ Технологический стек  
* | Компонент       | Технологии                     |
* | --------------- | ------------------------------ |
* | Frontend        | Flutter 3.16+, Dart 3.2+       |
* | Backend         | .NET 8.0, C# Web API           |
* | База данных     | PostgreSQL 15+, Supabase       |
* | Карты           | Google Maps API, OpenStreetMap |
* | Контейнеризация | Docker, Docker Compose         |
* | CI/CD           | GitHub Actions                 |

# Зависимости  
dependencies:  
  flutter:  
    sdk: flutter  

  supabase_flutter: ^2.10.3  
  cupertino_icons: ^1.0.8  
  http: ^1.2.2  
  html: ^0.15.4  
  flutter_map: ^8.2.2  
  latlong2: ^0.9.1  

  flutter_bloc: ^8.1.0  
  equatable: ^2.0.5  

dev_dependencies:  
  flutter_test:  
    sdk: flutter  
  flutter_lints: ^6.0.0    

# 📱 Сборка для продакшена  

Android APK  
flutter build apk --release  

Android App Bundle  
flutter build appbundle --release  

iOS  
flutter build ios --release  

Backend  
dotnet publish -c Release -o ./publish  
# 🔄 Методология разработки  
Проект разработан по принципам Agile Scrum с соблюдением всех ключевых практик  

# 🔧 Процесс разработки
🏗️ Клиент-серверная архитектура  
Проект реализован по классическому клиент-серверному шаблону с четким разделением ответственности:  
graph TB  
    subgraph Client["📱 Клиент (Flutter)"]  
        UI[UI Layer<br/>Provider/MVVM]  
        Logic[Business Logic<br/>Use Cases]  
        DataClient[Data Layer<br/>Repository Pattern]  
    end  
    
    subgraph Server["🖥️ Сервер (.NET API)"]  
        Controllers[Controllers<br/>REST API]  
        Services[Business Services]  
        DataServer[Data Access<br/>EF Core]  
        DB[(PostgreSQL<br/>+ Supabase)]  
    end  
    
    Cache[(Redis<br/>Кэш)]  
    
    UI --> Logic  
    Logic --> DataClient  
    DataClient -.->|HTTPS/JSON| Controllers  
    Controllers --> Services  
    Services --> DataServer  
    DataServer --> DB  
    Services -.->|Кэш| Cache  
