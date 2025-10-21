import json

def lambda_handler(event, context):
    """
    Ödev koşullarını sağlayan serverless fonksiyon
    1. HTTP tetikleyicisi
    2. Parametre alıp işlem yapan (isim alıp karşılama)
    """
    
    # HTTP tetikleyicisinden parametre al
    name = "Serverless Öğrenci" # Varsayılan değer
    
    try:
        if event.get('queryStringParameters') and 'name' in event['queryStringParameters']:
            name = event['queryStringParameters']['name']
        elif event.get('body'):
            # Eğer POST veya başka bir body varsa (opsiyonel)
            body = json.loads(event['body'])
            if 'name' in body:
                name = body['name']
    except Exception as e:
        print(f"Parametre okuma hatası: {e}")

    # CloudWatch logları
    print(f"Fonksiyon tetiklendi. İsim parametresi: {name}")

    response_message = f"Merhaba {name}, bu fonksiyon bulutta (AWS Lambda) çalışıyor ve ödevimi tamamlıyor!"

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': response_message,
            'challenge': 'Göreviniz Başarıyla Tamamlandı!',
            'info': 'Parametreyi URL’den `?name=YeniIsim` şeklinde değiştirebilirsiniz.'
        })
    }