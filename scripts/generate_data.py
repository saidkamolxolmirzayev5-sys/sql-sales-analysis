"""
Sintetik chakana savdo ma'lumotlarini yaratish (UzRetail).

Fiktiv do'konlar tarmog'i: 12 ta filial, 6 ta viloyat, 2024-2025 yillar.
Natija: data/ papkasida 5 ta CSV fayl.

Ishga tushirish:
    python scripts/generate_data.py
"""
from datetime import date, timedelta
from pathlib import Path

import numpy as np
import pandas as pd

SEED = 42
START = date(2024, 1, 1)
END = date(2025, 12, 31)
N_CUSTOMERS = 6000
OUT = Path(__file__).resolve().parent.parent / "data"

rng = np.random.default_rng(SEED)

# --- Filiallar -------------------------------------------------------------
STORES = [
    # store_id, nomi, viloyat, shahar, ochilgan sana, hajm koeffitsienti
    (1, "Chilonzor", "Toshkent", "Toshkent", "2021-03-01", 1.6),
    (2, "Yunusobod", "Toshkent", "Toshkent", "2021-09-15", 1.4),
    (3, "Sergeli", "Toshkent", "Toshkent", "2022-05-10", 1.1),
    (4, "Mirzo Ulug'bek", "Toshkent", "Toshkent", "2024-06-01", 1.0),
    (5, "Farg'ona markaz", "Farg'ona", "Farg'ona", "2022-02-01", 1.2),
    (6, "Qo'qon", "Farg'ona", "Qo'qon", "2022-08-20", 1.1),
    (7, "Marg'ilon", "Farg'ona", "Marg'ilon", "2023-04-01", 0.8),
    (8, "Samarqand markaz", "Samarqand", "Samarqand", "2021-11-01", 1.3),
    (9, "Kattaqo'rg'on", "Samarqand", "Kattaqo'rg'on", "2023-10-01", 0.7),
    (10, "Andijon", "Andijon", "Andijon", "2022-11-15", 1.0),
    (11, "Namangan", "Namangan", "Namangan", "2023-01-20", 0.9),
    (12, "Buxoro", "Buxoro", "Buxoro", "2025-03-01", 0.9),
]
stores = pd.DataFrame(
    STORES,
    columns=["store_id", "store_name", "region", "city", "opened_date", "size"],
)

# --- Mahsulotlar -----------------------------------------------------------
CATALOG = {
    # kategoriya: [(nomi, narx so'mda, tannarx ulushi, mashhurlik)]
    "Non va shirinliklar": [
        ("Obi non", 4000, 0.70, 9), ("Patir non", 7000, 0.65, 5),
        ("Bulochka", 3500, 0.60, 4), ("Tort \"Napoleon\"", 85000, 0.55, 1),
        ("Pechene 500g", 18000, 0.62, 3), ("Shokolad 100g", 16000, 0.68, 4),
        ("Vafli 300g", 14000, 0.63, 2),
    ],
    "Sut mahsulotlari": [
        ("Sut 1L", 12000, 0.78, 9), ("Qatiq 1L", 11000, 0.75, 6),
        ("Qaymoq 400g", 19000, 0.72, 3), ("Tvorog 500g", 28000, 0.74, 3),
        ("Pishloq 300g", 42000, 0.70, 2), ("Sariyog' 200g", 32000, 0.76, 3),
        ("Kefir 1L", 13000, 0.75, 4),
    ],
    "Ichimliklar": [
        ("Suv 1.5L", 4500, 0.55, 8), ("Gazli ichimlik 1.5L", 13000, 0.60, 6),
        ("Sharbat 1L", 17000, 0.64, 4), ("Ko'k choy 100g", 15000, 0.58, 5),
        ("Qora choy 100g", 16000, 0.58, 3), ("Qahva 100g", 48000, 0.60, 2),
        ("Energetik 0.5L", 14000, 0.55, 2),
    ],
    "Go'sht mahsulotlari": [
        ("Mol go'shti 1kg", 115000, 0.82, 4), ("Qo'y go'shti 1kg", 125000, 0.83, 3),
        ("Tovuq 1kg", 42000, 0.80, 6), ("Kolbasa 500g", 45000, 0.72, 3),
        ("Sosiska 500g", 32000, 0.70, 3), ("Qiyma 1kg", 105000, 0.81, 3),
    ],
    "Meva-sabzavot": [
        ("Kartoshka 1kg", 6000, 0.70, 8), ("Piyoz 1kg", 5000, 0.68, 7),
        ("Sabzi 1kg", 5500, 0.68, 7), ("Pomidor 1kg", 14000, 0.66, 6),
        ("Bodring 1kg", 12000, 0.66, 5), ("Olma 1kg", 16000, 0.64, 5),
        ("Banan 1kg", 22000, 0.70, 4), ("Limon 1kg", 30000, 0.65, 2),
    ],
    "Bakaleya": [
        ("Guruch 1kg", 22000, 0.80, 6), ("Un 2kg", 16000, 0.82, 5),
        ("Shakar 1kg", 14000, 0.84, 5), ("O'simlik yog'i 1L", 24000, 0.83, 6),
        ("Makaron 400g", 9000, 0.70, 5), ("Grechka 1kg", 18000, 0.75, 3),
        ("Tuz 1kg", 3000, 0.60, 3), ("Tuxum 10 dona", 17000, 0.80, 7),
    ],
    "Maishiy kimyo": [
        ("Kir yuvish kukuni 3kg", 65000, 0.68, 2), ("Idish yuvish vositasi", 15000, 0.60, 3),
        ("Sovun", 6000, 0.55, 3), ("Shampun", 38000, 0.58, 2),
        ("Tish pastasi", 17000, 0.57, 2), ("Hojatxona qog'ozi 4 dona", 14000, 0.62, 4),
    ],
}
rows, pid = [], 1
for cat, items in CATALOG.items():
    for name, price, cost_share, pop in items:
        rows.append((pid, name, cat, price, int(round(price * cost_share, -1)), pop))
        pid += 1
products = pd.DataFrame(
    rows, columns=["product_id", "product_name", "category", "unit_price", "unit_cost", "popularity"]
)

# --- Mijozlar --------------------------------------------------------------
store_weights = stores["size"] / stores["size"].sum()
cust_store = rng.choice(stores["store_id"], size=N_CUSTOMERS, p=store_weights)
store_open = dict(zip(stores.store_id, pd.to_datetime(stores.opened_date).dt.date))
days_total = (END - START).days

reg_dates = []
for sid in cust_store:
    first = max(START - timedelta(days=365), store_open[sid])
    span = (END - timedelta(days=30) - first).days
    # yangi mijozlar asta-sekin qo'shiladi: ro'yxatdan o'tish sanasi chapga og'gan
    reg_dates.append(first + timedelta(days=int(span * rng.beta(1.3, 1.6))))

customers = pd.DataFrame({
    "customer_id": np.arange(1, N_CUSTOMERS + 1),
    "gender": rng.choice(["Ayol", "Erkak"], size=N_CUSTOMERS, p=[0.58, 0.42]),
    "birth_year": rng.integers(1960, 2006, size=N_CUSTOMERS),
    "home_store_id": cust_store,
    "registered_date": reg_dates,
})
# har bir mijozning faolligi turlicha (sodiq va tasodifiy xaridorlar)
loyalty = rng.lognormal(mean=0.0, sigma=0.9, size=N_CUSTOMERS)
# ~35% mijoz biror vaqtda tark etadi (churn)
churn = np.where(
    rng.random(N_CUSTOMERS) < 0.35,
    [d + timedelta(days=int(rng.integers(30, 400))) for d in customers.registered_date],
    END + timedelta(days=1),
)
customers_active = customers.assign(loyalty=loyalty, churn_date=churn)


# --- Mavsumiylik -----------------------------------------------------------
def demand_factor(d: date) -> float:
    f = 1.0
    f *= {0: 0.95, 1: 0.92, 2: 0.95, 3: 1.0, 4: 1.12, 5: 1.25, 6: 1.15}[d.weekday()]
    f *= {1: 0.90, 2: 0.92, 3: 1.18, 4: 1.0, 5: 0.98, 6: 1.02, 7: 0.97,
          8: 1.03, 9: 1.05, 10: 1.0, 11: 1.08, 12: 1.30}[d.month]
    if d.month == 3 and 18 <= d.day <= 22:  # Navro'z
        f *= 1.35
    if d.month == 12 and d.day >= 25:  # Yangi yil
        f *= 1.45
    f *= 1 + 0.18 * (d - START).days / days_total  # yillik o'sish
    return f


def promo_rate(d: date) -> float:
    if d.month == 3 and 15 <= d.day <= 25:
        return 0.35
    if d.month == 11 and d.day >= 20:
        return 0.40
    if d.month == 12:
        return 0.25
    return 0.10


# --- Buyurtmalar -----------------------------------------------------------
BASE_ORDERS = 5.0  # filial hajmi 1.0 bo'lgan do'konning o'rtacha kunlik buyurtmalari
pop_p = (products.popularity / products.popularity.sum()).to_numpy()
prod_ids = products.product_id.to_numpy()
prod_price = dict(zip(products.product_id, products.unit_price))
HOURS = np.arange(8, 23)
hour_p = np.array([2, 3, 4, 5, 6, 6, 5, 5, 6, 8, 10, 11, 10, 7, 4], dtype=float)
hour_p /= hour_p.sum()
PAY = ["Naqd", "Karta (Uzcard/Humo)", "Click", "Payme"]

pid_of = dict(zip(products.product_name, products.product_id))
# tez-tez birga olinadigan juftliklar: (asosiy, qo'shimcha, ehtimollik)
PAIRS = [
    (pid_of["Obi non"], pid_of["Sut 1L"], 0.45),
    (pid_of["Kartoshka 1kg"], pid_of["Piyoz 1kg"], 0.55),
    (pid_of["Mol go'shti 1kg"], pid_of["Sabzi 1kg"], 0.40),
]

cust_by_store = {
    sid: customers_active[customers_active.home_store_id == sid] for sid in stores.store_id
}

orders, items = [], []
oid = 1
d = START
while d <= END:
    yr_shift = (d - START).days / days_total
    # yillar davomida naqd ulushi kamayib, Click/Payme o'sadi
    pay_p = np.array([0.42 - 0.14 * yr_shift, 0.33, 0.13 + 0.07 * yr_shift, 0.12 + 0.07 * yr_shift])
    pay_p /= pay_p.sum()
    for s in stores.itertuples():
        if d < store_open[s.store_id]:
            continue
        pool = cust_by_store[s.store_id]
        pool = pool[(pool.registered_date <= d) & (pool.churn_date > d)]
        if pool.empty:
            continue
        n = rng.poisson(BASE_ORDERS * s.size * demand_factor(d))
        if n == 0:
            continue
        w = pool.loyalty.to_numpy() / pool.loyalty.sum()
        buyers = rng.choice(pool.customer_id.to_numpy(), size=n, p=w)
        promo = promo_rate(d)
        for cid in buyers:
            hour = int(rng.choice(HOURS, p=hour_p))
            ts = pd.Timestamp(d) + pd.Timedelta(hours=hour, minutes=int(rng.integers(0, 60)))
            orders.append((oid, ts, int(cid), s.store_id, rng.choice(PAY, p=pay_p)))
            k = min(1 + rng.poisson(2.6), 12)
            basket = rng.choice(prod_ids, size=k, replace=False, p=pop_p)
            for a, b, prob in PAIRS:
                if a in basket and b not in basket and rng.random() < prob:
                    basket = np.append(basket, b)
            for p in basket:
                qty = int(1 + rng.poisson(0.6))
                disc = rng.choice([0.05, 0.10, 0.15]) if rng.random() < promo else 0.0
                items.append((oid, int(p), qty, prod_price[p], float(disc)))
            oid += 1
    d += timedelta(days=1)

orders = pd.DataFrame(orders, columns=["order_id", "order_ts", "customer_id", "store_id", "payment_method"])
order_items = pd.DataFrame(items, columns=["order_id", "product_id", "quantity", "unit_price", "discount"])
order_items.insert(0, "order_item_id", np.arange(1, len(order_items) + 1))

# --- Saqlash ---------------------------------------------------------------
OUT.mkdir(exist_ok=True)
stores.drop(columns="size").to_csv(OUT / "stores.csv", index=False)
products.drop(columns="popularity").to_csv(OUT / "products.csv", index=False)
customers.drop(columns="home_store_id").assign(home_store_id=cust_store).to_csv(OUT / "customers.csv", index=False)
orders.to_csv(OUT / "orders.csv", index=False)
order_items.to_csv(OUT / "order_items.csv", index=False)

print(f"stores: {len(stores)}, products: {len(products)}, customers: {len(customers)}")
print(f"orders: {len(orders)}, order_items: {len(order_items)}")
