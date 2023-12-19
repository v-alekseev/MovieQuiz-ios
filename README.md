## **MovieQuiz**

MovieQuiz - это приложение с квизами о фильмах из топ-250 рейтинга и самых популярных фильмах по версии IMDb.

## **Ссылки**

[Макет Figma](https://www.figma.com/file/l0IMG3Eys35fUrbvArtwsR/YP-Quiz?node-id=34%3A243)

[API IMDb](https://imdb-api.com/api#Top250Movies-header)

[Шрифты](https://code.s3.yandex.net/Mobile/iOS/Fonts/MovieQuizFonts.zip)

## **Описание приложения**
Одностраничное приложение с квизами о фильмах из топ-250 рейтинга и самых популярных фильмов IMDb. Пользователь приложения последовательно отвечает на вопросы о рейтинге фильма. По итогам каждого раунда игры показывается статистика о количестве правильных ответов и лучших результатах пользователя. Цель игры — правильно ответить на все 10 вопросов раунда.

## **Стек**
- Архитектура MVP и  MVC.
- Вёрстка в Storyboard. Дизайн в Figma.
- Сетевой запрос с помощью URLSession.
- Добавлены  Unit Tests

## API key 
Для корректной работы приложения нужно получить API Key на сайте https://imdb-api.com/.  Далее ключ нужно указать в url в коде [MoviesLoader.swift](https://github.com/v-alekseev/MovieQuiz-ios/blob/project_sprint_3_start/MovieQuiz/Services/MoviesLoader.swift).
