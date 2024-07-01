
-- Soru 1: Customers isimli bir veritabanı ve verilen veri setindeki değişkenleri içerecek FLO isimli bir tablo oluşturunuz.

CREATE DATABASE Customers;

-- Soru 2: Kaç farklı müşterinin alışveriş yaptığını gösterecek sorguyu yazınız.

SELECT COUNT(DISTINCT(master_id)) AS DISTINCT_KISI_SAYISI FROM FLO;

-- Soru 3: Toplam yapılan alışveriş sayısı ve ciroyu getirecek sorguyu yazınız.

SELECT 
	SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SIPARIS_SAYISI,
	ROUND(SUM(customer_value_total_ever_online + customer_value_total_ever_offline), 2) AS TOPLAM_CIRO
FROM FLO;

-- Soru 4: Alışveriş başına ortalama ciroyu getirecek sorguyu yazınız.

SELECT
	ROUND(SUM(customer_value_total_ever_online + customer_value_total_ever_offline) /
	SUM(order_num_total_ever_online + order_num_total_ever_offline), 2) AS SIPARIS_BASINA_ORT_CIRO
FROM FLO;

-- Soru 5: En son alışveriş yapılan kanal (last_order_channel) üzerinden yapılan alışverişlerin toplam ciro ve alışveriş sayılarını getirecek sorguyu yazınız.

SELECT
	last_order_channel AS EN_SON_ALISVERISIN_YAPILDIGI_KANAL,
    SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS TOPLAM_CIRO,
	SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SIPARIS_SAYISI
FROM FLO
GROUP BY last_order_channel;

-- Soru 6: Store type kırılımında elde edilen toplam ciroyu getiren sorguyu yazınız.

SELECT
	store_type AS MAGAZA_TURU,
	SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS TOPLAM_CIRO
FROM FLO
GROUP BY store_type;

-- Soru 7: Yıl kırılımında alışveriş sayılarını getirecek sorguyu yazınız. Yıl olarak müşterinin ilk alışveriş tarihi (first_order_date) yılını baz alınız.

SELECT
	YEAR(first_order_date) AS YIL,
	SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SIPARIS_SAYISI
FROM FLO
GROUP BY YEAR(first_order_date)
ORDER BY 2 DESC;

-- Soru 8: En son alışveriş yapılan kanal kırılımında alışveriş başına ortalama ciroyu hesaplayacak sorguyu yazınız.

SELECT
	last_order_channel AS EN_SON_ALISVERISIN_YAPILDIGI_KANAL,
	SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS TOPLAM_CIRO,
	SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SIPARIS_SAYISI,
	ROUND(SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / SUM(order_num_total_ever_online + order_num_total_ever_offline), 2) AS VERIMLILIK
FROM FLO
GROUP BY last_order_channel;

-- Soru 9: Son 12 ayda en çok ilgi gören kategoriyi getiren sorguyu yazınız.

SELECT
	interested_in_categories_12,
	COUNT(*) AS FREKANS_BILGISI
FROM FLO
GROUP BY interested_in_categories_12
ORDER BY 2 DESC;

-- SORU 10: En çok tercih edilen store_type bilgisini getiren sorguyu yazınız.

SELECT TOP 1
	store_type,
	COUNT(*) AS FREKANS_BILGISI
FROM FLO
GROUP BY store_type
ORDER BY 2 DESC;

-- Soru 11: En son alışveriş yapılan kanal (last_order_channel) bazında, en çok ilgi gören kategoriyi ve bu kategoriden ne kadarlık alışveriş yapıldığını getiren sorguyu yazınız.
	
	SELECT DISTINCT last_order_channel,
(
	SELECT TOP 1 interested_in_categories_12
	FROM FLO  WHERE last_order_channel = f.last_order_channel
	GROUP BY interested_in_categories_12
	ORDER BY 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) DESC
),
(
	SELECT TOP 1 SUM(order_num_total_ever_online+order_num_total_ever_offline)
	FROM FLO  WHERE last_order_channel = f.last_order_channel
	GROUP BY interested_in_categories_12
	ORDER BY 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) DESC 
)
FROM FLO F;

-- Soru 12: En çok alışveriş yapan kişinin ID’sini getiren sorguyu yazınız.

SELECT TOP 1 master_id
	FROM FLO
	GROUP BY master_id
	ORDER BY SUM(order_num_total_ever_online + order_num_total_ever_offline) DESC;

-- Soru 13: En çok alışveriş yapan kişinin alışveriş başına ortalama cirosunu ve alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu yazınız.

SELECT *, 
	ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI), 2)  AS SIPARIS_BASINA_ORTALAMA_CIRO
FROM 
	(SELECT TOP 1
	master_id,
	SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS TOPLAM_CIRO,
	SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SIPARIS_SAYISI
	FROM FLO
	GROUP BY Master_id
	ORDER BY TOPLAM_CIRO DESC
	) D;

-- Soru 14: En çok alışveriş yapan (ciro bazında) ilk 100 kişinin alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu yazınız.

SELECT
    D.master_id,
    D.TOPLAM_CIRO,
    D.TOPLAM_SIPARIS_SAYISI,
    ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI), 2) AS SIPARIS_BASINA_ORTALAMA_CIRO,
    DATEDIFF(DAY, D.first_order_date, D.last_order_date) AS ILK_VE_SON_ALISVERIS_GUN_FARKI,
    ROUND(DATEDIFF(DAY, D.first_order_date, D.last_order_date) / D.TOPLAM_SIPARIS_SAYISI, 1) AS ALISVERIS_SIKLIGI
FROM
    (
    SELECT TOP 100
        master_id,
        first_order_date,
        last_order_date,
        SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS TOPLAM_CIRO,
        SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SIPARIS_SAYISI
    FROM FLO
    GROUP BY master_id, first_order_date, last_order_date
    ORDER BY TOPLAM_CIRO DESC
    ) AS D;

-- Soru 15: En son alışveriş yapılan kanal (last_order_channel) kırılımında en çok alışveriş yapan müşteriyi getiren sorguyu yazınız.

SELECT DISTINCT last_order_channel,
	
	(SELECT TOP 1
		master_id
	FROM FLO WHERE last_order_channel = f.last_order_channel
	GROUP BY master_id
	ORDER BY SUM(customer_value_total_ever_online + customer_value_total_ever_offline) DESC) AS EN_COK_ALISVERIS_YAPAN_MUSTERI,

	(SELECT TOP 1
		SUM(customer_value_total_ever_online + customer_value_total_ever_offline)
	FROM FLO WHERE last_order_channel = f.last_order_channel
	GROUP BY master_id
	ORDER BY SUM(customer_value_total_ever_online + customer_value_total_ever_offline) DESC) AS TOPLAM_CIRO
FROM FLO f;

-- Soru 16: En son alışveriş yapan kişinin ID’lerini getiren sorguyu yazınız. Max son tarihte birden fazla alışveriş yapan ID bulunmakta, bunları da getiriniz.

SELECT
	master_id,
	last_order_date
FROM FLO
WHERE last_order_date = (SELECT MAX(Last_order_date) FROM FLO);



		


