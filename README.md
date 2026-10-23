# 🛒 UzRetail: chakana savdo tarmog'ining SQL tahlili

O'zbekistondagi 12 filialli oziq-ovqat do'konlari tarmog'ining 2 yillik
(2024–2025) savdo ma'lumotlarini **PostgreSQL** yordamida tahlil qilish.
Loyiha biznes savollariga javob beradi: qayerda o'sish bor, qaysi mahsulot
foyda keltiradi, qaysi mijozlar ketib qolmoqda.

> ⚠️ Ma'lumotlar **sintetik**: ular `scripts/generate_data.py` orqali yaratilgan.
> Do'kon nomlari va raqamlar o'ylab topilgan, real kompaniyaga aloqasi yo'q.

**Texnologiyalar:** PostgreSQL · SQL (CTE, window functions, FILTER, NTILE) · Python (pandas, numpy)

---

## 📦 Ma'lumotlar

| Jadval | Qatorlar | Tavsif |
|---|---:|---|
| `stores` | 12 | Filiallar: viloyat, shahar, ochilgan sana |
| `products` | 49 | Mahsulotlar: 7 kategoriya, narx va tannarx |
| `customers` | 6 000 | Mijozlar: jins, tug'ilgan yil, ro'yxatdan o'tgan sana |
| `orders` | 53 968 | Cheklar: sana-vaqt, filial, to'lov usuli |
| `order_items` | 202 059 | Chek qatorlari: miqdor, narx, chegirma |

```
stores ──< orders >── customers
             │
             └──< order_items >── products
```

Barcha tahlillar `v_sales` view'idan foydalanadi. U har bir chek qatori uchun
tushum (`revenue`), tannarx (`cost`) va foyda (`profit`) hisoblaydi.

---

## 🚀 Ishga tushirish

```bash
createdb -U postgres uzretail
psql -U postgres -d uzretail -f sql/00_schema.sql      # jadvallar + ma'lumot + view
psql -U postgres -d uzretail -f sql/01_kpi_overview.sql
```

Ma'lumotlarni qaytadan yaratish uchun: `pip install -r requirements.txt && python scripts/generate_data.py`

---

## 🔍 Tahlillar va natijalar

| # | Fayl | Biznes savoli | SQL usullari |
|---|---|---|---|
| 1 | [01_kpi_overview](sql/01_kpi_overview.sql) | Biznes qanchalik o'sdi? | CTE, `LAG` |
| 2 | [02_monthly_trend](sql/02_monthly_trend.sql) | Mavsumiylik qanday? | `DATE_TRUNC`, MoM/YoY, sirpanuvchi o'rtacha |
| 3 | [03_region_yoy](sql/03_region_yoy.sql) | Qaysi hudud tez o'smoqda? | `FILTER`, ulush |
| 4 | [04_store_ranking](sql/04_store_ranking.sql) | Filiallar reytingi | `RANK() OVER (PARTITION BY)` |
| 5 | [05_category_mix](sql/05_category_mix.sql) | Qaysi kategoriya foydali? | `SUM(SUM()) OVER ()` |
| 6 | [06_abc_analysis](sql/06_abc_analysis.sql) | Asosiy pulni nima keltiradi? | Kumulyativ yig'indi, `STRING_AGG` |
| 7 | [07_rfm_segmentation](sql/07_rfm_segmentation.sql) | Mijozlar segmentlari | `NTILE`, RFM |
| 8 | [08_cohort_retention](sql/08_cohort_retention.sql) | Mijozlar qaytib keladimi? | Kohort tahlil |
| 9 | [09_market_basket](sql/09_market_basket.sql) | Nima birga sotib olinadi? | Self-join, support / confidence / lift |
| 10 | [10_weekday_load](sql/10_weekday_load.sql) | Qaysi kunlar band? | `ISODOW` |
| 11 | [11_payment_trend](sql/11_payment_trend.sql) | Naqd puldan voz kechish sur'ati | Choraklar bo'yicha ulush |
| 12 | [12_discount_impact](sql/12_discount_impact.sql) | Chegirma o'zini oqlaydimi? | Marja tahlili |

### 1. Umumiy o'sish
| Yil | Tushum, mln so'm | Foyda, mln so'm | Marja | Cheklar | Mijozlar | O'rtacha chek | O'sish |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2024 | 3 005 | 770 | 25.6% | 24 370 | 3 378 | 123 310 | — |
| 2025 | 3 625 | 935 | 25.8% | 29 598 | 4 395 | 122 481 | **+20.6%** |

O'sishning asosiy manbai o'rtacha chek emas, balki **mijozlar soni** (+30%).
O'rtacha chek deyarli o'zgarmagan.

### 2. Mavsumiylik
- **Dekabr** yilning eng kuchli oyi (2025: 424 mln, noyabrga nisbatan +31%).
- **Mart** (Navro'z) ikkinchi cho'qqi: fevralga nisbatan +50–57%.
- **Yanvar–fevral** eng sust davr. Bu vaqtda aksiyalar va zaxirani kamaytirish uchun qulay.

### 3. Hududlar
| Viloyat | 2024 | 2025 | O'sish | 2025 ulushi |
|---|---:|---:|---:|---:|
| Toshkent | 1 177 | 1 442 | **+22.5%** | 39.8% |
| Farg'ona | 796 | 865 | +8.7% | 23.9% |
| Samarqand | 523 | 568 | +8.6% | 15.7% |
| Andijon | 268 | 293 | +9.4% | 8.1% |
| Namangan | 242 | 248 | **+2.7%** | 6.8% |
| Buxoro | — | 209 | yangi filial | 5.8% |

Toshkentning o'sishi qisman 2024-yil iyunda ochilgan Mirzo Ulug'bek filiali hisobiga.
**Namangan** deyarli o'smayapti, sababini alohida o'rganish kerak.

### 4. Kategoriyalar: tushum ≠ foyda
| Kategoriya | Tushum ulushi | Foyda ulushi | Marja |
|---|---:|---:|---:|
| Go'sht mahsulotlari | **36.8%** | 26.7% | **18.7%** |
| Bakaleya | 14.3% | 10.5% | 18.9% |
| Sut mahsulotlari | 12.9% | 12.2% | 24.2% |
| Meva-sabzavot | 11.5% | 14.3% | 32.0% |
| Ichimliklar | 9.4% | 14.6% | **39.9%** |
| Maishiy kimyo | 8.1% | 11.6% | 37.0% |
| Non va shirinliklar | 7.1% | 10.1% | 36.7% |

Go'sht tushumning uchdan bir qismini beradi, lekin marjasi eng past.
**Ichimliklar** va **maishiy kimyo** kam sotilsa-da, foydaga katta hissa qo'shadi.
Ularni kassa yoniga va ko'zga tashlanadigan joylarga qo'yish foydali.

### 5. ABC tahlil
- **A sinf:** 27 mahsulot (55%) → tushumning 80%. Bularda tovar hech qachon tugamasligi kerak.
- **C sinf:** 9 mahsulot → atigi 5.3%. Lekin ular orasida *Obi non* va *Suv* bor:
  arzon, ammo mijozni do'konga olib keladigan tovarlar. Shuning uchun ularni assortimentdan chiqarmaslik kerak.

### 6. RFM: mijozlar segmentlari
| Segment | Mijozlar | O'rtacha cheklar | Tushum ulushi |
|---|---:|---:|---:|
| Chempionlar | 24.8% | 24.0 | **57.5%** |
| Sodiq mijozlar | 19.3% | 10.3 | 19.1% |
| Yangi / istiqbolli | 8.5% | 2.5 | 2.0% |
| **Xavf ostida** | 15.8% | 9.6 | **14.6%** |
| Yo'qotilgan | 24.2% | 2.2 | 5.2% |
| E'tibor talab | 7.4% | 2.3 | 1.6% |

Mijozlarning chorak qismi tushumning yarmidan ko'pini beradi.
**"Xavf ostida"** guruhi (823 kishi) ilgari faol bo'lgan, lekin o'rtacha 288 kundan beri xarid qilmagan.
Ular tushumning 15% ini tashkil qiladi. Ularni qaytarish kampaniyasi (SMS, shaxsiy chegirma) birinchi navbatdagi vazifa.

### 7. Kohort tahlil
Yangi mijozlarning o'rtacha **~47%** i keyingi oyda qaytadi, 12 oydan keyin esa **~29%** i qoladi.
Eng katta yo'qotish birinchi 3 oyda bo'ladi, shuning uchun sodiqlik dasturi aynan shu davrga qaratilishi kerak.

### 8. Savat tahlili
| Juftlik | Birga uchrashi | Confidence | Lift |
|---|---:|---:|---:|
| Kartoshka → Piyoz | 8.1% cheklar | 60.3% | **3.27** |
| Mol go'shti → Sabzi | 3.3% | 46.2% | **3.24** |
| Obi non → Sut | 7.8% | 52.8% | **2.56** |

Kartoshka olgan har 10 mijozdan 6 tasi piyoz ham oladi. Bu mahsulotlarni yonma-yon qo'yish
va "osh to'plami" (go'sht + sabzi + piyoz + guruch + yog') aksiyasini o'tkazish mumkin.

### 9. Yuklama va to'lovlar
- **Shanba** eng band kun (17%), **seshanba** eng sust (12.3%). Cheklarning ~42% i soat 17:00–21:00 oralig'iga to'g'ri keladi.
- **Naqd pul** ulushi 2 yilda 40.6% dan **29%** gacha tushdi. Click va Payme birgalikda **26% → 38%** ga o'sdi.

### 10. Chegirmalar
| Chegirma | O'rtacha miqdor | Marja |
|---|---:|---:|
| 0% | 1.60 | 26.7% |
| 5% | 1.58 | 22.9% |
| 10% | 1.61 | 18.7% |
| 15% | 1.61 | **14.0%** |

Chegirma bir chekdagi **xarid miqdorini oshirmayapti** (1.6 dona), faqat marjani kamaytiryapti.
Aksiyalarni hamma uchun emas, faqat "xavf ostida" mijozlar uchun maqsadli qilish samaraliroq.

---

## 💡 Asosiy tavsiyalar
1. **"Xavf ostida"** segmentidagi 823 mijozni qaytarish: tushumning 15% i shu guruhda.
2. **Ommaviy chegirmalarni** maqsadli takliflar bilan almashtirish: hozir ular faqat marjani yeyapti.
3. **Yuqori marjali** kategoriyalarni (ichimliklar, maishiy kimyo) ko'proq ko'rinadigan joyga qo'yish.
4. **Juft mahsulotlarni** yonma-yon joylashtirish va to'plam aksiyalari.
5. **Namangan** filialining sust o'sish sababini o'rganish.

---

## 📁 Tuzilma
```
sql-sales-analysis/
├── data/                  # CSV ma'lumotlar
├── scripts/
│   └── generate_data.py   # sintetik ma'lumot generatori
└── sql/
    ├── 00_schema.sql      # jadvallar, yuklash, indekslar, v_sales
    └── 01–12_*.sql        # tahlil so'rovlari
```

Ushbu ma'lumotlar asosidagi dashboard: [powerbi-sales-dashboard](https://github.com/saidkamolxolmirzayev5-sys/powerbi-sales-dashboard)
