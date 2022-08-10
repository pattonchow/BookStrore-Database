USE finalProject;

-- 1.	注册：用户填写好用户名等信息后，插入这条数据到Customer （finish）
DELIMITER $$
DROP PROCEDURE IF EXISTS register;
CREATE PROCEDURE register (
IN
userName_ VARCHAR(45),
_password_ VARCHAR(45),
email_ VARCHAR(45),
phone_number_ VARCHAR(11),
State VARCHAR(255),
City VARCHAR(255),
Zip VARCHAR(255),
Street VARCHAR(255))
BEGIN
INSERT INTO Customer(userName, password_, email, phone_number, defaultState, defaultCity, defaultZip, defaultStreet, loginStatus, is_vip) 
		VALUES(userName_, _password_, email_, phone_number_, State, City, Zip, Street, 0, 0);
END$$

-- CALL register ('test', '123', 'test@neu.edu', '11223344', 'MA', 'Boston', '02148', 'Pleasant St');
SET GLOBAL log_bin_trust_function_creators = 1;
-- 2. 检测注册用户名是否重复, 返回值如果为1则该用户名可用，如果为0则不可用。 (finish)
DROP FUNCTION IF EXISTS check_useful_username;
CREATE FUNCTION check_useful_username(user_ VARCHAR(45))
RETURNS INT
BEGIN
DECLARE user1 VARCHAR(45) DEFAULT 'NULL';
SELECT userName 
	FROM Customer
    WHERE userName = user_
    INTO user1;
IF user1 = 'NULL' THEN RETURN 1;
END IF;
RETURN 0;
END$$


-- 2.登陆：用户输入用户名和密码之后，进行验证。如果登录成功，修改登录状态  (finish)
-- 如果登录成功，返回id。登录失败，返回0.
-- function for verifying user

DROP FUNCTION IF EXISTS verify;
CREATE FUNCTION verify(user_ VARCHAR(45), pwd VARCHAR(45))
RETURNS INT
BEGIN
DECLARE user1 VARCHAR(45) DEFAULT 'NULL';
DECLARE id INT DEFAULT 0;
-- DECLARE pwd1 VARCHAR(45);
SELECT userName FROM Customer WHERE userName = user_ AND password_ = pwd INTO user1;
SELECT userId FROM Customer WHERE userName = user_ AND password_ = pwd INTO id;
IF user1 != 'NULL'
	THEN UPDATE Customer SET loginStatus = 1 WHERE userId = id;
		RETURN id;
END IF;
RETURN 0;
END$$

-- SELECT verify ('test', '123') AS result;


-- 3. 获取登录状态 （输入id）
DROP FUNCTION IF EXISTS check_login_or_not;
CREATE FUNCTION check_login_or_not(id INT)
RETURNS INT
BEGIN
RETURN (SELECT loginStatus FROM Customer WHERE userId = id);
END$$

-- SELECT check_login_or_not('test');

-- 4.添加默认地址（trigger） (finish)
DROP TRIGGER IF EXISTS add_default_address;
CREATE TRIGGER add_default_address
AFTER INSERT 
ON Customer FOR EACH ROW
BEGIN
INSERT INTO Address (userId, phone, state, city,zip,street) VALUES(new.userId, new.phone_number, new.defaultState, new.defaultCity, new.defaultZip, new.defaultStreet);
END$$

-- 5. 添加地址 （输入为用户id， 地址的各种信息） (finish)
DROP PROCEDURE IF EXISTS add_address;
CREATE PROCEDURE add_address(IN id INT, phone_ VARCHAR(11), state_ VARCHAR(255), city_ VARCHAR(255), zip_ VARCHAR(255), street_ VARCHAR(255))
BEGIN
INSERT INTO Address (userId, phone, state, city,zip,street) VALUES(id, phone_, state_, city_, zip_, street_);
END$$


-- 6. 显示所有地址 (finish)
DROP PROCEDURE IF EXISTS show_address;
CREATE PROCEDURE show_address (IN id INT)
BEGIN
SELECT phone, state, city, zip, street
	FROM Address
	WHERE userId = id;
END$$

-- 7. 修改默认地址 （输入ID， 以及address的各种信息，进行更新）
DROP PROCEDURE IF EXISTS change_default_address;
CREATE PROCEDURE change_default_address(IN id INT, phone_ VARCHAR(11), state_ VARCHAR(255), city_ VARCHAR(255), zip_ VARCHAR(255), street_ VARCHAR(255))
BEGIN
UPDATE CUSTOMER SET phone_number = phone_, defaultState = state_, defaultCity = city_, defaultZip = zip_, defaultStreet = street_;
END$$

-- 8. 修改密码（在用户登录之后，即登录状态为1时(上面有获取登录状态的function)，可以进行此操作。）(finish)
DROP PROCEDURE IF EXISTS change_password;
CREATE PROCEDURE change_password(IN id INT, old_pwd VARCHAR(45), new_pwd VARCHAR(45))
BEGIN
DECLARE check_user INT DEFAULT id;
SELECT userId 
	FROM Customer 
	WHERE userId = id AND password_ = old_pwd
    INTO check_user;
IF check_user = id
	THEN UPDATE Customer SET password_ = new_pwd WHERE userId = id;
END IF;
END$$

-- CALL change_password(1, '123', '12');

-- 9. logout (输入为ID，修改登录状态)

DROP PROCEDURE IF EXISTS user_logout;
CREATE PROCEDURE user_logout (IN id INT)
BEGIN
UPDATE Customer SET loginStatus = 0 WHERE userId = id;
END$$

-- 分割线--------------------------------------------------以下是对于Store的操作


-- 1.注册商铺:用户填写好用户名等信息后，插入这条数据到Store （finish）
DROP PROCEDURE IF EXISTS register_store;
CREATE PROCEDURE register_store (
IN store_name VARCHAR(45), pwd VARCHAR(45), email_ VARCHAR(45))
BEGIN
INSERT INTO Store (storeName, password_, email, loginStatus) VALUES (store_name, pwd, email_, 0);
END$$

-- CALL register_store('Amazon', '123', 'amazon@gmail.com');


-- 2. 检测store注册用户名是否重复, 返回值如果为1则该用户名可用，如果为0则不可用。(finish)
DROP FUNCTION IF EXISTS check_useful_storename;
CREATE FUNCTION check_useful_storename(store VARCHAR(45))
RETURNS INT
BEGIN
DECLARE store1 VARCHAR(45) DEFAULT 'NULL';
SELECT storeName 
	FROM Store
    WHERE storeName = store
    INTO store1;
IF store1 = 'NULL' THEN RETURN 1;
END IF;
RETURN 0;
END$$

-- SELECT check_useful_storename ('Amazon');

-- 3.登陆：store输入用户名和密码之后，进行验证。如果登录成功，修改登录状态 (finish)
-- 如果登录成功，返回id。登录失败，返回0.
-- function for verifying store
DROP FUNCTION IF EXISTS verify_store;
CREATE FUNCTION verify_store(store VARCHAR(45), pwd VARCHAR(45))
RETURNS INT
BEGIN
DECLARE store1 VARCHAR(45) DEFAULT 'NULL';
DECLARE id INT DEFAULT 0;
SELECT storeName FROM Store WHERE storeName = store AND password_ = pwd INTO store1;
SELECT storeId FROM Store WHERE storeName = store AND password_ = pwd INTO id;
IF store1 != 'NULL'
	THEN UPDATE Store SET loginStatus = 1 WHERE storeId = id;
		RETURN id;
END IF;
RETURN 0;
END$$

-- SELECT verify_store ('Amazon','123') AS result;


-- 4. 获取store登录状态 （输入id）
DROP FUNCTION IF EXISTS check_store_login_or_not;
CREATE FUNCTION check_store_login_or_not(id INT)
RETURNS INT
BEGIN
RETURN (SELECT loginStatus FROM Store WHERE storeId = id);
END$$

-- SELECT check_store_login_or_not(1);


-- 5. 修改密码（在用户登录之后，即登录状态为1时(上面有获取登录状态的function)，可以进行此操作。）（finish）
DROP PROCEDURE IF EXISTS change_store_password;
CREATE PROCEDURE change_store_password(IN id INT, old_pwd VARCHAR(45), new_pwd VARCHAR(45))
BEGIN
DECLARE check_store INT DEFAULT id;
SELECT storeId 
	FROM Store 
	WHERE storeId = id AND password_ = old_pwd
    INTO check_store;
IF check_store = id
	THEN UPDATE Store SET password_ = new_pwd WHERE storeId = id;
END IF;
END$$

-- CALL change_store_password(1, '123', '12');


-- 6. logout (输入为ID，修改登录状态)

DROP PROCEDURE IF EXISTS store_logout;
CREATE PROCEDURE store_logout (IN id INT)
BEGIN
UPDATE Store SET loginStatus = 0 WHERE storeId = id;
END$$


-- 分割线 -------------------------------------------接下来是书

-- 1. 插入书籍信息到book （信息源于网络，属于设置数据库的一部分)
DROP PROCEDURE IF EXISTS add_book;
CREATE PROCEDURE add_book (IN book VARCHAR(45), price DOUBLE, author_ VARCHAR(45), publish VARCHAR(45))
BEGIN
DECLARE exist VARCHAR(45) DEFAULT 'NULL';
SELECT bookName	
	FROM Book
    WHERE bookName = book
    INTO exist;
IF exist = 'NULL'
	THEN INSERT INTO Book(bookName, bookPrice, author, publisher) VALUES (book, price, author_, publish);
END IF;
END$$

-- CALL add_book ('lotr', 24.5, 'aaaa', 'bbbb');

-- 2. store添加商品到 StoretoBook(需要提前验证是否已经在店铺内存在，若存在跳到修改信息的步骤). (finish)
DROP PROCEDURE IF EXISTS store_add_book;
CREATE PROCEDURE store_add_book (IN id INT, book_name VARCHAR(45), vip_price DOUBLE, non_vip_price DOUBLE, storagenumber INT)
BEGIN
DECLARE bookid2 INT DEFAULT 0;
SELECT bookId
	FROM Book
	WHERE LOWER(bookName) = LOWER(book_name)
    INTO bookid2;
IF bookid2 = 0
 	THEN INSERT INTO Book(bookName, bookPrice) VALUES (book_name, non_vip_price);
		SELECT bookId FROM Book WHERE LOWER(bookName) = LOWER(book_name) INTO bookid2;
END IF;
INSERT INTO StoretoBook (storeId, bookId, vipPrice, nonVipPrice, storagenum) VALUES (id, bookid2, vip_price, non_vip_price, storagenumber);
END$$

-- CALL store_add_book(1, 'lotr', 20.5, 24.5, 5);


-- 3. store 查询某本书是否在自己的商店中存在(返回值为id则存在，0为不存在) (finish)
DROP FUNCTION IF EXISTS store_have_book;
CREATE FUNCTION store_have_book (id INT, book_name VARCHAR(45))
RETURNS VARCHAR(45)
BEGIN
-- DECLARE exist VARCHAR(45) DEFAULT 'This book is not in your store now.';
DECLARE bookid1 INT DEFAULT 0;
DECLARE bookid2 INT DEFAULT 0;
SELECT bookId -- 查询书库是否有这本书 
	FROM Book
    WHERE LOWER(bookName) = LOWER(book_name)
    INTO bookid1;
IF bookid1 = 0
	THEN RETURN bookid1;
ELSE -- 查询该商店是否有这本书， 因为是用书的id来控制，所以需要查两次
	SELECT bookId
		FROM StoretoBook
        WHERE storeId = id AND bookId = bookid1
        INTO bookid2;
END IF;
RETURN bookid2;
END$$

-- SELECT store_have_book(1, 'lotr') AS result;
    
-- 3. store 修改书的库存 (需要查询这本书是否存在, 返回值0为修改失败，1 为修改成功) （finidh）
DROP FUNCTION IF EXISTS change_book_storage;
CREATE FUNCTION change_book_storage ( id INT, book_name VARCHAR(45), new_storage_number INT)
RETURNS INT
BEGIN
DECLARE exist_book INT;
SELECT store_have_book (id, book_name) INTO exist_book;
IF exist_book = 0
	THEN RETURN exist_book; -- 没有这本书，返回0，前端实现：if == 0: 更新失败，找不到这本书
ELSE
	UPDATE StoretoBook SET storagenum = new_storage_number WHERE storeId = id AND bookId = exist_book;
END IF;
RETURN 1;
END$$

-- SELECT change_book_storage (1, 'lotr', 20);


-- 4. store 修改书的价格 (返回值为0修改失败，1 为修改成功) (finish)
DROP FUNCTION IF EXISTS change_book_price;
CREATE FUNCTION change_book_price ( id INT, book_name VARCHAR(45), new_vip_price DOUBLE, new_non_vip_price DOUBLE)
RETURNS INT
BEGIN
DECLARE exist_book INT;
SELECT store_have_book (id, book_name) INTO exist_book;
IF exist_book = 0
	THEN RETURN exist_book; -- 没有这本书，返回0，前端实现：if == 0: 更新失败，找不到这本书
ELSE
	UPDATE StoretoBook SET vipPrice = new_vip_price, nonVipPrice = new_non_vip_price WHERE storeId = id AND bookId = exist_book;
END IF;
RETURN 1;
END$$


-- SELECT change_book_price (1, 'lotr', 18, 19);








-- 5. store查询自己商店所有书的信息(finish)
DROP PROCEDURE IF EXISTS view_all_books;
CREATE PROCEDURE view_all_books(IN id INT)
BEGIN
SELECT bookName, vipPrice, nonVipPrice, storagenum, author, publisher
	FROM
	(SELECT bookId, vipPrice, nonVipPrice, storagenum
		FROM StoretoBook
		WHERE storeId = 1) AS new_table1
	LEFT JOIN Book
    USING (bookId);
END$$

-- CALL view_all_books(1);
    


-- 6. store下架某本书（需要在前端做error handling,同时需要提前查询这本书是否存在，调用store_have_book function）(finish)
DROP PROCEDURE IF EXISTS drop_book;
CREATE PROCEDURE drop_book(IN id INT, book_name VARCHAR(45))
BEGIN
DECLARE bookid1 INT;
SELECT bookId
	FROM
	(SELECT bookId, bookName
		FROM StoretoBook
		LEFT JOIN BOOK
		USING (bookId)) AS new_table1
	INTO bookid1;
DELETE FROM StoretoBook WHERE storeId = id AND bookId = bookid1;
END$$

-- CALL drop_book(1,'lotr');
 





-- store对书的操作基本完成--------------------------接下来是用户对书的操作-------


-- 1. 根据书名搜索书籍信息，即所有出售这本书的商店和书的信息 （finish）
DROP PROCEDURE IF EXISTS user_find_book;
CREATE PROCEDURE user_find_book(IN book VARCHAR(45))
BEGIN
	SELECT * FROM Book
LEFT JOIN
	(SELECT *
	FROM Category
	LEFT JOIN
	(SELECT * FROM BooktoCategory
		LEFT JOIN
		(SELECT *
			FROM 
			(SELECT *
				FROM Book
				LEFT JOIN StoretoBook
				USING (bookId))AS new_table1
			WHERE bookName = 'lotr') AS new_table2
		USING (bookId)) AS new_table3
	USING (categoryId)
	WHERE bookName = 'lotr') AS new_table4
USING (bookId);
END$$

-- CALL user_find_book('lotr');


-- 2. user选择书加入购物车( 用户选择一个商铺的一本书，添加的数量需要小于库存的数量，否则添加失败(此功能在前端进行实现)。需要在前端try except) (finish)

DROP PROCEDURE IF EXISTS user_add_book_to_shoppingcart;
CREATE PROCEDURE user_add_book_to_shoppingcart(IN id INT, bookid1 INT, vip_price DOUBLE, non_vipprice DOUBLE, storeid1 INT, num INT) -- num为用户选择要添加的数量
BEGIN
DECLARE exist INT DEFAULT 0;
DECLARE totalprice1 DOUBLE DEFAULT 0;
DECLARE isVip INT DEFAULT 0;
DECLARE totalPrice2 INT DEFAULT 0; -- 如果购物车存在这个商店出售的这本书，取出其数量和价格。
DECLARE booknum2 INT DEFAULT 0;
SELECT totalPrice
	FROM ShoppingCart
    WHERE userId = id AND bookId = bookid1 AND storeId = storeid1
    INTO totalPrice2;
SELECT booknum
	FROM ShoppingCart
    WHERE userId = id AND bookId = bookid1 AND storeId = storeid1
    INTO booknum2;
SELECT bookid1 
	FROM ShoppingCart
    WHERE userId = id AND storeId = storeid1
    INTO exist;
SELECT is_vip 
	FROM Customer
    WHERE userId = id
    INTO isVip;
IF isVip = 0 THEN SET totalprice1 = num * non_vipprice; -- 判断是不是vip，计算总价
ELSE SET totalprice1 = num * vip_price;
END IF;
IF exist = 0 -- 如果不存在这个商店出售的这本书，则在shoppingcart中加入一条记录
	THEN INSERT INTO ShoppingCart (userId, storeId, bookId, booknum, totalPrice) VALUES (id, storeid1, bookid1, num, totalprice1);
ELSE
	UPDATE ShoppingCart SET totalPrice = totalPrice2 + totalprice1, booknum = booknum2 + num WHERE userId = id AND storeId = storeid1 AND bookId = bookid1;
END IF;
END$$

-- CALL user_add_book_to_shoppingcart (1,1,20.5,24.5,1,2);

-- 3. 修改购物车的内容(如果数量修改超出库存，返回0，修改成功返回1) (finish)
DROP FUNCTION IF EXISTS change_shoppingcart_num;
CREATE FUNCTION change_shoppingcart_num(id INT, storeid1 INT, bookid1 INT, num INT) -- num为前端输入的修改后的数量
RETURNS INT
BEGIN
DECLARE checknum INT DEFAULT 0;
DECLARE vip_price DOUBLE DEFAULT 0;
DECLARE non_vip_price DOUBLE DEFAULT 0;
DECLARE isVip INT DEFAULT 1;
SELECT storageNum 
	FROM StoretoBook
    WHERE storeId = storeid1 AND bookId = bookid1
    INTO checknum;
IF num > checknum
	THEN RETURN 0;
END IF;
SELECT vipPrice
	FROM StoretoBook
    WHERE storeId = storeid1 AND bookId = bookid1
    INTO vip_price;
SELECT nonVipPrice
	FROM storetoBook
    WHERE storeId = storeid1 AND bookId = bookid1
    INTO non_vip_price;
SELECT is_vip
	FROM Customer
    WHERE userId = id
    INTO isVip;
IF isVip = 1
	THEN UPDATE ShoppingCart SET booknum = num, totalPrice = num * vip_price WHERE userId = id AND storeId = storeid1 AND bookId = bookid1;
ELSE UPDATE ShoppingCart SET booknum = num, totalPrice = num * non_vip_price WHERE userId = id AND storeId = storeid1 AND bookId = bookid1;
END IF;
RETURN 1;
END$$

-- SELECT change_shoppingcart_num (1,1,1,6);

-- 4. 用户删除购物车的内容 (finish)
DROP PROCEDURE IF EXISTS drop_book_in_shoppingcart;
CREATE PROCEDURE drop_book_in_shoppingcart(IN id INT, storeid1 INT, bookid1 INT)
BEGIN
DELETE FROM ShoppingCart WHERE userId = id AND storeId = storeid1 AND bookId = bookid1;
END$$

-- 5. 显示购物车的内容（finish）
DROP PROCEDURE IF EXISTS show_shoppingcart;
CREATE PROCEDURE show_shoppingcart (IN id INT)
BEGIN
SELECT *
	FROM ShoppingCart
    WHERE userId = id;
END$$

-- 6.添加快递公司（数据来源于网站，属于现成数据）
DROP PROCEDURE IF EXISTS add_delivery_company;
CREATE PROCEDURE add_delivery_company(IN name_ VARCHAR(45), unit DOUBLE)
BEGIN
INSERT INTO DeliveryCompany (companyName, unitPrice) VALUES (name_, unit);
END$$

-- CALL add_delivery_company('Fedex', 1.5);

-- 7. 显示快递公司供用户选择
DROP PROCEDURE IF EXISTS show_delivery_company;
CREATE PROCEDURE show_delivery_company()
BEGIN
SELECT * FROM DeliveryCompany;
END$$
-- 添加到订单之前，选择快递公司之后，需要选择收货地址，调用show_address方法
-- 7. 用户从购物车添加到订单（包括选择快递公司，添加数据到order和order details,查看是否超过库存，如果添加成功返回1，添加失败返回0）（finish）
DROP FUNCTION IF EXISTS add_book_to_order;
CREATE FUNCTION add_book_to_order( id INT, storeid1 INT, bookid1 INT, num INT, total_price DOUBLE, develiveryid INT, develiveryunitPrice DOUBLE, addressid1 INT)
RETURNS INT
BEGIN
	DECLARE checknum INT DEFAULT 0;
	DECLARE total DOUBLE DEFAULT 0;
SELECT storageNum
	FROM StoretoBook
	WHERE storeId = storeid1
    INTO checknum;
IF num > checknum
	THEN RETURN 0;
END IF;
SET total = total_price + develiveryunitPrice;
INSERT INTO _Order (userId, orderStatus, storeId, bookId, companyId, booknum, totalPrice, addressId) VALUES (id, 'submitted', storeid1, bookid1, develiveryid, num, total, addressid1);
RETURN 1;
END $$


-- 8. trigger 删除购物车中对应的数据以及减掉商家的库存(finish)
DROP TRIGGER IF EXISTS after_add_to_order_delete_shoppingcart;
CREATE TRIGGER after_add_to_order_delete_shoppingcart
AFTER INSERT 
ON _Order FOR EACH ROW
BEGIN
DECLARE oriNum INT DEFAULT 0;
DELETE FROM ShoppingCart WHERE userId = new.userId AND storeId = new.storeId AND bookId = new.bookId;
-- DECLARE currentNum INT DEFAULT 0;
SELECT storageNum
	FROM StoretoBook
    WHERE storeId = new.storeId AND bookId = new.bookId
    INTO oriNum;
UPDATE StoretoBook SET storageNum = oriNum - new.booknum WHERE storeId = new.storeId AND bookId = new.bookId;
END$$


-- SELECT add_book_to_order(1,1,1,2, 49, 1,1.5, 1);


    


-- 9.用户查询订单(查询结果为：订单编号，店名，书名，订单状态，运货公司，书的数量，总价)，注意没有订单的情况(try except (finish but not test)
DROP PROCEDURE IF EXISTS user_find_order;
CREATE PROCEDURE user_find_order(IN id INT)
BEGIN
SELECT orderId, userName, storeName, bookName, orderStatus, companyName, booknum, totalPrice, phone, state, city, zip, street
	FROM _Order
    JOIN Customer USING (userId)
    JOIN Book USING (bookId)
    JOIN Store USING (storeId)
    JOIN DeliveryCompany USING (companyId)
    JOIN Address USING (addressId)
    WHERE _Order.userId = id;
END$$

-- CALL user_find_order(1);

-- 10. store 修改订单状态 (finish but not test)
DROP PROCEDURE IF EXISTS store_change_status;
CREATE PROCEDURE store_change_status(orderid1 INT, newStatus VARCHAR(45)) -- 此处id为storeid, newStatus为store在前端填写或选择的状态，建议设置选择【Ship, out of delivery, Delivery, Finished 】一定要有Finished
BEGIN
UPDATE _Order SET orderStatus = newStatus WHERE orderId = orderid1;
END$$

-- 分割线 -------------------------以下是评论相关

-- 1. 用户可以查询所有已完成的订单(finished)  (finish)
DROP PROCEDURE IF EXISTS check_status;
CREATE PROCEDURE check_status(IN id INT)
BEGIN
SELECT orderId, storeId, bookId, userName, storeName, bookName, orderStatus, companyName, booknum, totalPrice, phone, state, city, zip, street
	FROM _Orderu
    JOIN Customer USING (userId)
    JOIN Book USING (bookId)
    JOIN Store USING (storeId)
    JOIN DeliveryCompany USING (companyId)
    JOIN Address USING (addressId)
    WHERE _Order.userId = id AND orderStatus = 'Finished';
END$$
    

-- 2. 用户可以对已完成（finished）的订单进行评价 c (finish)

DROP PROCEDURE IF EXISTS create_comment;
CREATE PROCEDURE create_comment(IN id INT, orderid1 INT, storeid1 INT, bookid1 INT, comment_ VARCHAR(255)) -- id 为userid
BEGIN
INSERT INTO Evaluation(storeId, bookId, eva) VALUES(storeid1, bookid1, comment_);
END$$

-- 分割线，以下是图书分类 ------------------------------------

-- 添加图书分类 (手动添加 )
DROP PROCEDURE IF EXISTS add_catagory;
CREATE PROCEDURE add_catagory(IN bookname1 VARCHAR(45), categoryname1 VARCHAR(45))
BEGIN
DECLARE bookid1 INT DEFAULT 0;
DECLARE categoryid1 INT DEFAULT 0;
SELECT bookId
	FROM Book
    WHERE bookName = bookname1
    INTO bookid1;
SELECT categoryId
	FROM Category
    WHERE categoryy = categoryname1
    INTO categoryid1;
IF bookid1 != 0 AND categoryid1 != 0 THEN INSERT BooktoCategory(bookId, categoryId) VALUES (bookid1, categoryid1);
END IF;
END$$

-- CALL add_catagory('lotr', 'Adventure');




















