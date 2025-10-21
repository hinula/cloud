exports.handler = async (event) => {
    let name = "Serverless Öğrenci"; 
    
    // Parametre alma
    if (event.queryStringParameters && event.queryStringParameters.name) {
        name = event.queryStringParameters.name;
    } 
    
    console.log(`Fonksiyon tetiklendi. İsim: ${name}`);

    const responseBody = {
        message: `Merhaba ${name}, bu fonksiyon bulutta (AWS Lambda) çalışıyor ve ödevimi tamamlıyor!`,
        challenge: "Göreviniz Başarıyla Tamamlandı!",
        runtime: "Node.js ile JSON çıktı"
    };
    
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json', 
            'Access-Control-Allow-Origin': '*' 
        },
        body: JSON.stringify(responseBody)
    };
};
