1) SELECT customer_id, revenue_per_customer, avg_rental_days  FROM (SELECT 
	se_c.customer_id AS customer_id,
	ROUND(SUM(se_p.amount)) AS revenue_per_customer,
ROUND(AVG(CAST(se_r.return_date AS Date) - CAST(se_r.rental_date AS Date)),2) AS avg_rental_days
FROM public.rental AS se_r
INNER JOIN public.customer AS se_c
ON se_r.customer_id = se_c.customer_id
INNER JOIN public.payment AS se_p
ON se_p.customer_id = se_c.customer_id




GROUP BY se_c.customer_id) as t 
WHERE customer_id = 318;

2) 
SELECT rental_date, customer_id FROM (SELECT 
	se_p.customer_id, se_r.rental_date
FROM public.payment AS se_p 
LEFT JOIN public.rental AS se_r
ON se_r.customer_id = se_p.customer_id ) AS t 
WHERE rental_date IS NULL

3)SELECT
	se_c.customer_id,
	COUNT(SE_R.rental_id) AS total_films_rented

FROM public.customer AS se_c
INNER JOIN RENTAL AS se_r
	ON se_c.customer_id = se_r.customer_id
GROUP BY se_c.customer_id
ORDER BY COUNT(SE_R.rental_id) DESC

4)SELECT
    se_c.city,
    se_st.store_id,
    AVG(films_rented) AS avg_films_rented_per_customer
FROM (
    SELECT
        se_st.store_id,
        se_c.city,
        se_cu.customer_id,
        COUNT(se_r.rental_id) AS films_rented
FROM PUBLIC.store AS se_st
INNER JOIN public.address AS se_a
	ON se_st.address_id = se_a.address_id
INNER JOIN public.city AS se_c
	ON se_a.city_id = se_c.city_id
INNER JOIN public.customer AS se_cu
	ON se_st.store_id = se_cu.store_id
INNER JOIN public.rental AS se_r
	ON se_cu.customer_id = se_r.customer_id
GROUP BY
        se_st.store_id,
        se_c.city,
        se_cu.customer_id
) AS films_per_customer
INNER JOIN city AS se_c 
ON films_per_customer.city = se_c.city
INNER JOIN store AS se_st 
ON films_per_customer.store_id = se_st.store_id
GROUP BY
    se_c.city,
    se_st.store_id;


5) WITH film_rental AS (
    SELECT
        se_f.film_id,
        COUNT(se_r.rental_id) AS rental_count
    FROM
        public.film AS se_f
        INNER JOIN public.inventory AS se_inv 
		ON se_f.film_id = se_inv.film_id
        INNER JOIN public.rental AS se_R 
		ON se_inv.inventory_id = se_r.inventory_id
    GROUP BY
        se_f.film_id
),
avg_film_rental AS (
    SELECT AVG(rental_count) AS avg_rental_count
    FROM film_rental
)
SELECT
    se_f.film_id,
    se_f.title,
    se_f.description,
    se_fr.rental_count
FROM public.film AS se_f
INNER JOIN film_rental AS  se_fr 
ON se_f.film_id = se_fr.film_id
INNER JOIN avg_film_rental AS  se_avg 
ON se_fr.rental_count > se_avg.avg_rental_count
LEFT JOIN public.inventory AS se_inv ON se_f.film_id = se_inv.film_id
WHERE se_inv.film_id IS NULL;

9)SELECT
    se_st.store_id,
    se_st.manager_staff_id,
    SUM(rental_rev.rental_revenue) AS rental_revenue,
    SUM(payment_rev.payment_revenue) AS payment_revenue
FROM (
    SELECT
        se_i.store_id,
        se_r.customer_id,
        SUM(se_f.rental_rate) AS rental_revenue
    FROM public.inventory AS se_i
        INNER JOIN public.rental AS se_r 
		ON se_i.inventory_id = se_r.inventory_id
        INNER JOIN public.film se_f 
		ON se_i.film_id = se_f.film_id
    GROUP BY
        se_i.store_id,
        se_r.customer_id
) AS rental_rev
INNER JOIN (
    SELECT
        se_i.store_id,
        se_p.customer_id,
        SUM(se_p.amount) AS payment_revenue
    FROM public.payment AS se_p
        INNER JOIN public.rental AS se_r 
		ON se_p.rental_id = se_r.rental_id
        INNER JOIN public.inventory AS se_i 
		ON se_r.inventory_id = se_i.inventory_id
    GROUP BY
        se_i.store_id,
        se_p.customer_id
) AS payment_rev 
ON rental_rev.store_id = payment_rev.store_id AND rental_rev.customer_id = payment_rev.customer_id
INNER JOIN public.store AS se_st 
ON rental_rev.store_id = se_st.store_id
GROUP BY
    se_st.store_id,
    se_st.manager_staff_id
HAVING
    SUM(rental_rev.rental_revenue) > SUM(payment_rev.payment_revenue);