1. Trigger for Adding Products to an Order
Trigger: If the same product is added to an existing order, update the quantity of the product instead of creating a new record.
CREATE OR REPLACE FUNCTION add_product_to_order()
RETURNS TRIGGER
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM chi_tiet_don_hang
        WHERE id_order = NEW.id_order
        AND id_san_pham = NEW.id_san_pham
    ) THEN
        UPDATE chi_tiet_don_hang
        SET so_luong = so_luong + NEW.so_luong
        WHERE id_order = NEW.id_order
        AND id_san_pham = NEW.id_san_pham;
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER add_product_trigger
BEFORE INSERT ON chi_tiet_don_hang
FOR EACH ROW
EXECUTE FUNCTION add_product_to_order();

2. Trigger for Automatically Calculating the Total Price of an Order

CREATE OR REPLACE FUNCTION calculate_order_total()
RETURNS TRIGGER
AS $$
DECLARE
    total_price NUMERIC;
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        SELECT SUM(sp.gia * ctdh.so_luong) INTO total_price
        FROM chi_tiet_don_hang ctdh
        LEFT JOIN san_pham sp USING(id_san_pham)
        WHERE ctdh.id_order = NEW.id_order;

        UPDATE public."Order"
        SET tong_gia_tri = total_price
        WHERE id_order = NEW.id_order;

    ELSIF (TG_OP = 'DELETE') THEN
        SELECT SUM(sp.gia * ctdh.so_luong) INTO total_price
        FROM chi_tiet_don_hang ctdh
        LEFT JOIN san_pham sp USING(id_san_pham)
        WHERE ctdh.id_order = OLD.id_order;

        UPDATE public."Order"
        SET tong_gia_tri = total_price
        WHERE id_order = OLD.id_order;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_order_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON chi_tiet_don_hang
FOR EACH ROW
EXECUTE FUNCTION calculate_order_total();

3. Function to Calculate Total Revenue in a Date Range
CREATE OR REPLACE FUNCTION calculate_total_revenue(start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS NUMERIC
AS $$
DECLARE
    total_revenue NUMERIC;
BEGIN
    SELECT SUM(o.tong_gia_tri)
    INTO total_revenue
    FROM public."Order" o
    WHERE o.thoi_gian BETWEEN start_date AND end_date;
    RETURN total_revenue;
END;
$$ LANGUAGE plpgsql;

4. Delete Users with Zero Remaining Time and No Recent Orders
DELETE FROM "Nguoi_su_dung" nsd
WHERE nsd.thoi_gian_con_lai = INTERVAL '0'
AND NOT EXISTS (
    SELECT 1
    FROM public."Order" o
    WHERE o.id_user = nsd.id_user
    AND o.thoi_gian > CURRENT_DATE - INTERVAL '3 MONTH'
);

5. Procedure to Add a New Customer

CREATE OR REPLACE PROCEDURE add_customer(
    IN username VARCHAR(100),
    IN password VARCHAR(100),
    IN phone VARCHAR(100),
    IN id_card INT
)
AS $$
BEGIN
    INSERT INTO nguoi_su_dung (Ten_tk, matkhau, SDT, CCCD)
    VALUES (username, password, phone, id_card);
    
    RAISE NOTICE 'Successfully added a new customer!';
END;
$$ LANGUAGE plpgsql;

6. Display Products Out of Stock in 'Food' Category
SELECT Ten, Gia, So_luong_con_lai
FROM San_pham
WHERE So_luong_con_lai = 0 AND Loai_san_pham = 'food';

CREATE INDEX idx_san_pham ON San_pham (Loai_san_pham, So_luong_con_lai);

7. Function to Log User Login
CREATE OR REPLACE FUNCTION log_user_login(user_id INTEGER, machine_id INTEGER)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Lich_su_truy_cap (ID_User, ID_May, Thoi_gian)
    VALUES (user_id, machine_id, NOW());
END;
$$ LANGUAGE plpgsql;
8. Function to Convert Money to Time

CREATE OR REPLACE FUNCTION convert_money_to_time(user_id INTEGER, amount NUMERIC)
RETURNS VOID AS $$
DECLARE
    time_to_add INTERVAL;
BEGIN
    time_to_add := (amount / 10000 * INTERVAL '1 hour');

    UPDATE "Nguoi_su_dung"
    SET Thoi_gian_con_lai = Thoi_gian_con_lai + time_to_add
    WHERE ID_User = user_id;
END;
$$ LANGUAGE plpgsql;


9. Trigger to Notify When User's Time Runs Out

CREATE OR REPLACE FUNCTION check_remaining_time(user_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    remaining_time INTERVAL;
BEGIN
    SELECT Thoi_gian_con_lai INTO remaining_time
    FROM "Nguoi_su_dung"
    WHERE ID_User = user_id;

    IF remaining_time > INTERVAL '0' THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_time_expiration()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT check_remaining_time(NEW.ID_User) THEN
        RAISE EXCEPTION 'User % has exhausted their time.', NEW.ID_User;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_time_expiration_trigger
BEFORE INSERT ON Lich_su_truy_cap
FOR EACH ROW
EXECUTE FUNCTION notify_time_expiration();


10. Trigger to Automatically Update Remaining Time in User Table on Order Insertion

CREATE OR REPLACE FUNCTION update_remaining_time()
RETURNS TRIGGER AS $$
DECLARE
    product RECORD;
BEGIN
    FOR product IN
        SELECT sp.Ten, ctdh.So_luong
        FROM Chi_tiet_don_hang ctdh
        JOIN San_pham sp ON ctdh.ID_san_pham = sp.ID_san_pham
        WHERE ctdh.ID_Order = NEW.ID_Order
    LOOP
        IF product.Ten = '1-hour package' THEN
            UPDATE Nguoi_su_dung
            SET Thoi_gian_con_lai = Thoi_gian_con_lai + INTERVAL '1 hour' * product.So_luong
            WHERE ID_User = NEW.ID_User;
        ELSIF product.Ten = '2-hour package' THEN
            UPDATE Nguoi_su_dung
            SET Thoi_gian_con_lai = Thoi_gian_con_lai + INTERVAL '2 hours' * product.So_luong
            WHERE ID_User = NEW.ID_User;
        ELSIF product.Ten = '5-hour package' THEN
            UPDATE Nguoi_su_dung
            SET Thoi_gian_con_lai = Thoi_gian_con_lai + INTERVAL '5 hours' * product.So_luong
            WHERE ID_User = NEW.ID_User;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_remaining_time_trigger
AFTER INSERT ON "Order"
FOR EACH ROW
EXECUTE FUNCTION update_remaining_time();



