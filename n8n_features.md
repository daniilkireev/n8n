# ГЛОБАЛЬНОЕ ПРАВИЛО ЭТОГО ДОКУМЕНТА:
- БЕЗ КОНКРЕТНОГО УКАЗАНИЯ НА FEATURE К РАЗРАБОТКЕ - НИЧЕГО ДЕЛАТЬ НЕ НАДО!!!
- Если тебе ссылаются на этот файл в качестве ТЗ и не указывают конкретную feature к разработке - то без конкретного указания на конкретный раздел с именем Feature ничего разрабатывать НЕ НУЖНО! Запроси конкретные указания на имя Feature которую необходимо сейчас разработать.
- Если задание подразумевает только исследование, анализ или ПЛАНИРОВАНИЕ, то НЕ НУЖНО ничего разрабатывать! Необходимо провести только исследование, анализ или планирование.
- Текст этого файла возьми как основу и документацию для понимания бизнес сути проекта.
- Документ дополняется накопительным итогом - вверху самые старые разделы, внизу самые новые спецификации. Если какая-то спецификация ранних этапов входит в противоречение с реализованной спецификацией на более поздних этапах, то актуальной истиной является самая поздняя реализация.
- Учти все разделы всех фич описывающие логику работы, требования, техническую реализацию, ожидаемый результат и итоги реализации. Все требования должны учитываться накопительным итогом в реализации feature даже если они не указываются в тексте описания feature в явном виде.

## КОНТЕКСТ:
- В этой папке новый MVP проект n8n. Суть проекта - сделать минимальный n8n для интеграции с платформой чат-ботов Salebot.pro, сервисами Google (Google Sheets) и другими.
- Используются ДВА инстанса n8n: облачный cloud и локальный self-hosted.
- Все Workflow должны поддерживать одинаковую работу с cloud и self-hosted.

# ТЕХНИЧЕСКИЕ ТРЕБОВАНИЯ MVP:
- Указанные версии ПО - актуальные на текущий момент (Октябрь 2025). Разрешается использовать более новые стабильные версии ПО.
- Стек и версии указаны для локальной версии инстанса n8n.

## Стек и версии (self-hosted n8n)
- **n8n**: Self-hosted установка последней версии 1.118.2.
- **Python**: 3.13.14 и новее (обязательно использование `venv`).

## Сетевые настройки (self-hosted n8n)
- **Туннель для HTTPS**: Для внешних интеграций и webhook сервис доступен через отдельную VPS n8n.autsorsim.ru.
- **Доступ извне**: PROD - свободный доступ с самого хоста, а также из локальной сети. DEV - с любого компьютера.
- **Безопасность**: Для безопасного внешнего доступа — ограничивать фаерволом системы или туннелировать через SSH. Не настраивать повышенную безопасность в Docker/Compose.
- **URL локального n8n**: Собственный сервер n8n установлен и доступен по URL: http://192.168.1.60:5678/home/workflows.

## Контейнеризация (Docker/Compose) (self-hosted n8n)
- **Базовый образ**: оригинальный официальный n8n `docker.n8n.io/n8nio/n8n`.

## База данных и хранение состояния (при необходимости) (self-hosted n8n)
- **СУБД**: PostgreSQL 16, оригинальный официальный образ.

## Ограничения MVP
- Нет мониторингов/дашбордов/метрик активности поверх логов.
- Нет сложной ротации логов (только суточные файлы + простая очистка по 14 дням).
- Минимум абстракций, максимум простоты и надёжности.

## Безопасность
- **Токен API**: Все запросы к единому endpoint для внешних запросов /router/ должны иметь токен в header для post или ?x-api-key параметр для get равным `N8N_X_API_TOKEN_22DEE204206BEDE8`.

# CREDENTIALS
**salebotservicekey-447914-dc4c4ff21033.json**
```
{
  "type": "service_account",
  "project_id": "salebot-447914",
  "private_key_id": "dc4c4ff21033a85ef7f1dba5dba55446d31df228",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC3W/K267y2WcuB\neMABxmK0Cuxilk+ELmD+li+Anxz/WaPm+FJKVZNNusSuQuKXhWOKh2QGFT4mjbZf\n12EHD1Bpt29Z+wAWB3O0gLf8gf8KPmgeqPyjojIxJgVHgBAQPEvBrAAmShJxUIXL\nzOWtxMop1npyeFE6tgM2J+VfD/omtnb4TL60qIfXl97oxOffJd28yMcl211Nv6hk\nDpZv8ENDt4IrwiWUrvU+wLmN8q98dd/gkXg1bNIqZXtQsEKq5mfFWxJPmEgxOtAF\nXjB/ZpVc/8ZIfgs5f40KEtOrrXXNnNVVKaQJMuaXgOUFMJuXYalGj1BPc80jBa5g\n2HHjIVMNAgMBAAECggEAGYlxTt+bK0xrRu9x0m12XrvsuzhS/8ZT1PFG0WOXrsql\nxKvODjNH7jn2XYzMMS0vNWJw4FYCD22KOmPtTAXqfabCF+aY1viXuUp6FW1nf148\nsxR3BzU2R1kTwCcKVbCIHoOdi7eiROzhjYZOcLqpK1WHPT0blxE1dkvtKqW3gb+I\nDZBu/wUhwPxbCvYtrysGBqNjHgMa5G6lh5wiFpVDmAXngGh7cfy+nCCuODWtaDfl\nuBr8QcGvHmICtSQ63OGLkzLuE+iF7YtkSshOUTBTMr/tvBR923kAoMQyi7FPDU3o\n/48zOQnIqKtlCv4FqwseW4FoQeuRiFgx4WoGNXBIAwKBgQD2bXH2MpuNa7sJ+VSm\nn7jplb704bR5fnNxZ0QImInpsvwQ47LtErVUj477cb6dJzPr32migjVuW3lNi0b3\n/Z2np3y1B9Og+P12NeYUMTf+8Yo/Ua+GE0OL+FRTAiaKOFILmy62qwjKEC3D0GXq\nlX/hMbxbpB6JFGfxShVhJ97/CwKBgQC+e1S3YvT2Urq2L9B+k7q5ERR1Q8uLCiOz\nqehOdoBNcOJ/Vp3Jzn8PH5lWwng1c3EaIm2B9WjBnCdXdXqRkBb3004jbHcJlDmn\nNy9E+U60Zmg0jCMgQDlWPagj6dtu8ErD9rJVWIbfKbAdK6y0XwSz99R2gRIqGhhX\nG0e9H8QlRwKBgBGuHIULcHmfBxZaGyaxQvUPV1n+b5Jf7ixuukTbnNl1i/wyOf4k\nX3onqpyDtqdTzrfXmZ6dNPQr//H+UiMswQjsTVg3rYlZE+ZNS6qbNWdHMSIF3FAE\nRc5fDL2/47/69nf6tElK0CCfNIleBFHmU/x2MwtoJQC0xBhdtlb4I1mtAoGAVSC3\nLrIZ+g/lA9EAo+EP3O+mLfYbfEsOw5eWi6JoGrPtda1XHT6dCDw+AkktAe5SyLRE\nLoVnyMcpyetl2LIFocIctLYfyPcmgPWnuXKV2we9YGaUuDAbr9AkWdCE0eKv9z5E\nWuISfJ+b5p2DNKUWa/vBRyjN3mUFJcC6YepVdbcCgYBUsb0i/q9ziEL2jljLmIXk\nFqrTVv3+gz0J4YFuDJmU8snxicEHCPe6G5AAPIYYL64fj0Sn6EWHwudgW5c6e9R0\nS+Fnqr1GFQN1OuAkCi0ud/WHE8dsC3SObISFkutrtRyLI/deIm/mIlP/rVRscpsm\nn1GyQH2j6RRsdPqwZL/29g==\n-----END PRIVATE KEY-----\n",
  "client_email": "salebotservice@salebot-447914.iam.gserviceaccount.com",
  "client_id": "105419627675841471734",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/salebotservice%40salebot-447914.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
```

**OAUTH**

Client ID: 894712833073-on6aosobbo2rcdb8qm38uf7vsmd64p69.apps.googleusercontent.com
Client secret: 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

client_secret_894712833073-on6aosobbo2rcdb8qm38uf7vsmd64p69.apps.googleusercontent.com.json
```
{"web":{"client_id":"894712833073-on6aosobbo2rcdb8qm38uf7vsmd64p69.apps.googleusercontent.com","project_id":"salebot-447914","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_secret":"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"}}
```

** N8N API KEY n8n.autsorsim.ru **
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5Nzg1MDQzZS1lYmM0LTRmMTctYTJjYy02MTJkZmZlMWM4NDciLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzYyNDM5NDkyfQ.te1vVCRmhdjNzAsbJe2NMy-7VIHxtpuP0RxvTf9WMUs
```





# ФИЧА: Сокращение запросов к Google Sheets с помощью кэшинования справочных данных локально.

## Бизнес потребность:
Я использую google sheet как первоисточник данных, которые меняются довольно редко. Поэтому, для того чтобы при каждом запуске workflow не обращаться к ним напрямую, я хочу сначала скачать их себе в кэш, например, в data table таблицу и в workflow использовать уже данные из data table.

## ЗАДАЧА:
- Проанализируй возможные варианты решения, предложи лучшую архитектуру.
- Это MVP проект, поэтому все должно быть максимально просто и эффективно.
- Напиши такой workflow, который будет получать через сервисную учетную запись google содержимое листа google sheet, будет сохранять его 1 к 1 в таблицу data table.
- Запуск workflow нужно делать каждые 15 минут, либо вручную, либо при запуске через webhook /router?method=cache.update.
- webhook router уже существует, он является единой точкой endpoint для всех внешних запросов. После получения запроса он переадресует этот запрос 1:1 как body запроса в другие дочерние subworkflow со своими webhook и обратно после выполнения дочерних воркфлоу, он передает получившийся ответ json обратно вызывающей стороне. Поэтому в этом workflow должен быть webhook с url вида /cache/update для метода get. Плюс в get должен также передаваться в виде параметра токен доступа как ?x-api-key=LKSJDFIUYKJ (ключ апи).

## Ожидаемый результат:
- Workflow с оптимальной архитектурой, сохраняющий данные первоисточника google sheet локально в n8n в виде кэша. Работа с данными из кэш из других workflow.

## Итог реализации:
(раздел должен заполняться уже по итогам фактической реализации - в качестве документации накопительным итогом)


