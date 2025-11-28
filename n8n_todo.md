# КОНТЕКСТ:
Вся реализованная инфа перенесена в @n8n_featured.md. Здесь только TODO.


- 25.11.2025: Первый перевод через n8n процесс payment.single.json - прошел!

# Доработать:
- Добавить ответы ОШИБОК! (вообще привести к типовому виду).
- добавить просмотр табелей всех активных проектов.
- Добавить отчет о платеже (в комментарий?).
- Исключить строки подвала (брать только основную таблицу).
- Сделать подпроцесс единичной выплаты Альфы отдельно.
  - При этом главный процесс - "оркестратор" выплат через http post.
- Сделать индикатор как 0,001? (меньше копейки, чего в реальности точно не бывает; далее можно сделать 0,002 - Тбанк и т.п. хоть это и не правильно т.к. логика определения канала выплаты должна быть в "оркестраторе"; можно 0,001 - автоматом, а 0,002 вручную!).
- Лучше ответ формировать по Last Node, иначе каждый раз дублировать?
- Добавить "Запрет ЗП!", т.е. если человек имеет статус "Бан!", "Запрет" и т.п. то не переводить по умолчанию(?)






# Workflow: router.json

## Описание
- router - это workflow маршрутизатор, единая точка вызовов всех подчиненных workflow и возврата результата в унифицированном виде.

### WebHook Entry Point и OUTPUT

#### Пример OUTPUT из Webhook Entry Point
[
  {
    "headers": {
      "host": "n8n.autsorsim.ru",
      "x-real-ip": "62.84.112.69",
      "x-forwarded-for": "62.84.112.69",
      "x-forwarded-proto": "https",
      "connection": "close",
      "content-length": "754",
      "user-agent": "python-requests/2.31.0",
      "accept-encoding": "gzip, deflate",
      "accept": "*/*",
      "x-api-key": "N8N_X_API_TOKEN_22DEE204206BEDE8",
      "content-type": "application/x-www-form-urlencoded"
    },
    "params": {},
    "query": {},
    "body": {
      "method": "vacancy.message_text.get",
      "client_id": "841812011",
      "full_name": "Руслан",
      "phone": "79672953953",
      "order_id": "841812011-590513586",
      "messenger": "",
      "platform_id": "u2i-RolW6eiPGDWngAooFtfqFQ",
      "avito_order_id": "7769988616",
      "avito_order_price": "4400",
      "avito_order_title": "Комплектовщик на Склад электроники оплата ежедневн",
      "avito_order_url": "avito.ru/7769988616",
      "avito_profile": "https://avito.ru/user/fa5b5e8e48201dada97d646254e85cc2/profile?iid=7769988616&page_from=from_item_messenger&src=messenger&id=7769988616"
    },
    "webhookUrl": "https://n8n.autsorsim.ru/webhook/router",
    "executionMode": "production"
  }
]


### Respond to WebHook (workflow: router.json)

#### Описание разделов json
- Верхний уровень - метаданные workflow и execution
- input_data - входящий запрос полностью 1 в 1.
- result_data - результат выполнения подчиненного workflow.

#### Пример вывода Respond to Webhook
[
  {
    "webhookUrl": "https://n8n.autsorsim.ru/webhook/vacancy/message_text/get",
    "executionMode": "production",
    "execution_datetime": "2025-11-28T03:48:27.385-05:00",
    "execution_context": {
      "id": "6399",
      "mode": "production",
      "resumeUrl": "https://n8n.autsorsim.ru/webhook-waiting/6399",
      "resumeFormUrl": "https://n8n.autsorsim.ru/form-waiting/6399",
      "customData": {}
    },
    "workflow_context": {
      "active": true,
      "id": "ycJ8ZsUUu2deZibV",
      "name": "vacancy.message_text.get"
    },
    "input_data": {
      "method": "vacancy.message_text.get",
      "client_id": "841812011",
      "full_name": "Руслан",
      "phone": "79672953953",
      "order_id": "841812011-590513586",
      "messenger": "",
      "platform_id": "u2i-RolW6eiPGDWngAooFtfqFQ",
      "avito_order_id": "7769988616",
      "avito_order_price": "4400",
      "avito_order_title": "Комплектовщик на Склад электроники оплата ежедневн",
      "avito_order_url": "avito.ru/7769988616",
      "avito_profile": "https://avito.ru/user/fa5b5e8e48201dada97d646254e85cc2/"
    },
    "result_data": {
      "row_number": 7,
      "project": "Холодильник",
      "project_type": "Склад электроники",
      "speciality": "Комплектовщик с ТСД",
      "messages": {
        "wa_message_welcome_1": {
          "type": "text",
          "text": "Привет!"
        },
        "wa_message_welcome_2": {
          "type": "text",
          "text": "*Комплектовщик мужчина на склад электроники*"
        },
        "wa_message_welcome_3": {
          "type": "audio",
          "text": "В этом голосовом я рассказываю про работу!",
          "url": "https://files.salebot.pro/uploads/message_files/4bc7fd3387e9576773d403afdce990b0f8887c555a446b11ecfe02b97d3a794d.ogg"
        },
        "wa_message_welcome_4": {
          "type": "text",
          "text": ""
        },
        "wa_message_welcome_5": {
          "type": "text",
          "text": "*👉 Подходит вам?*"
        }
      }
    }
  }
]
