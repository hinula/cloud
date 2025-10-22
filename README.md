# 🌩️ Serverless Blog API & Frontend

Bu proje, **AWS Lambda**, **API Gateway**, **S3** ve **Terraform** kullanılarak oluşturulmuş tamamen **sunucusuz (serverless)** bir blog uygulamasıdır.  
Kullanıcı, API üzerinden “Hello”  uç noktsına erişebilir ve statik web arayüzü aracılığıyla bu verileri görüntüleyebilir.

---

## 🧠 Proje Amacı

Modern bulut tabanlı uygulamaların **sunucusuz mimari** ile nasıl geliştirileceğini öğrenmek ve bu mimarinin avantajlarını deneyimlemek amacıyla oluşturuldu.

**Motivasyon:**  
Sunucusuz mimari, geliştiricilerin altyapı yönetimiyle uğraşmadan sadece iş mantığına odaklanmasını sağlar. Bu projede hedefim;  
- AWS servislerini (Lambda, API Gateway, S3, CloudWatch) aktif kullanmak,  
- Terraform ile *Infrastructure-as-Code (IaC)* yaklaşımını öğrenmek,  
- Gerçek bir uygulamayı CI/CD mantığına uygun şekilde dağıtmaktı.

---

## 🧩 Proje Hakkında

Proje iki ana bileşenden oluşuyor:

1. **Backend (API Katmanı)**  
   - AWS Lambda fonksiyonları ile yazılmıştır.  
   - API Gateway üzerinden `/hello` uç noktası dış dünyaya açılmıştır.  
   - Fonksiyonlar Node.js ortamında çalışmaktadır.  

   Örnek uç nokta:
   - `https://k70hselmr2.execute-api.us-east-1.amazonaws.com/prod/hello`

2. **Frontend (Statik Blog Sayfası)**  
   - AWS S3 üzerinde statik web hosting olarak yayınlanmıştır.  
   - API uç noktalarıyla etkileşim kuran basit bir HTML/CSS/JS arayüzü içerir.  
   - Yayın adresi:  
     [http://my-serverless-project-blog-b37f6f94.s3-website-us-east-1.amazonaws.com/](http://my-serverless-project-blog-b37f6f94.s3-website-us-east-1.amazonaws.com/)

---

## ⚙️ Teknoloji Yığını

| Katman | Teknolojiler |
|--------|---------------|
| **Backend** | AWS Lambda, API Gateway, Node.js |
| **Infrastructure** | Terraform (IaC), AWS CloudWatch |
| **Frontend** | HTML, CSS, JavaScript |
| **Deployment** | AWS CLI, S3 Static Website Hosting |

---

## ✨ Özellikler

-  **Sunucusuz Mimari:** Tamamen AWS üzerinde, yönetilmesi gereken sunucu yok.  
-  **Hızlı Dağıtım:** Terraform kullanılarak tek komutla tüm altyapı oluşturulabilir.  
-  **Güvenli ve İzlenebilir:** CloudWatch loglarıyla Lambda fonksiyonları izlenebilir.  
-  **API Entegrasyonu:** Frontend, API Gateway uç noktalarıyla doğrudan iletişim kurar.  
-  **Infrastructure-as-Code:** Tüm yapı kod olarak versiyonlanabilir.  

---

## 🧭 Kurulum ve Çalıştırma
 " aws configure " yaparak Access key ID ve Secret access key aws'inizde düzgün yapılandırılımış bir IAM kullanıcısı yaparak Access key ID, Secret access key alabilirsiniz.
 Dosyayı klonladıktan sonra:
 cd terraform
 terraform init
 terraform plan 
 terraform apply

 Projeyle işiniz bitince terraform destroy yapabilirsiniz.

### 1️⃣ Depoyu Klonlayın
```bash
git clone https://github.com/kullanici/serverless-blog-project.git
cd serverless-blog-project
````

### Deneme
my-serverless-blog dosyasının içinde video var izleyebilirsiniz.
- CI/CD kısmında da olup olmadığını actions kısmından baktım ben sizde eknsiniz bu şekilde gerçekleştirebilirsiniz.(githubda setting kısmından keyleri yapılandırmayı unutmayın!!!) : 
<img width="842" height="361" alt="Ekran görüntüsü 2025-10-22 001119" src="https://github.com/user-attachments/assets/7ead404d-622a-444c-9105-c1841cebbbea" />



