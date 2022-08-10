import pymysql

def register(db):
    username = input("Please enter your username: ")

    sql_stmt = "SELECT check_useful_username('"+username+"') AS result"
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.execute(sql_stmt)

    # Username error handler
    while int(cursor.fetchall()[0]["result"]) != 1:
        print("The username is not available, please try again!")
        username = input("Please enter your username: ")
        sql_stmt = "SELECT check_useful_username('" + username + "') AS result"
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.execute(sql_stmt)
    cursor.close()

    password = input("Please enter your password: ")
    email = input("Please enter your email: ")
    phone = input("Please enter your phone number: ")
    state = input("Please enter your state: ")
    city = input("Please enter your city: ")
    street = input("Please enter your street: ")
    zip = input("Please enter your zip code: ")

    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('register', [username, password, email, phone, state, city, zip, street])
    db.commit()
    cursor.close()

def customer_login(db):
    username = input("Please enter your username: ")
    password = input("Please enter your password: ")
    sql_stmt = "SELECT verify ('"+ username +"','"+ password +"') AS result"
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.execute(sql_stmt)

    userId = cursor.fetchall()[0]['result']

    while userId == 0:
        print("Incorrect username/password, please try again!")
        username = input("Please enter your username: ")
        password = input("Please enter your password: ")
        sql_stmt = "SELECT verify ('" + username + "','" + password + "') AS result"
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.execute(sql_stmt)
        userId = cursor.fetchall()[0]['result']

    print("login successful")
    return userId


def add_address(id, db):

    # print("userid: ", id)
    phone = input("Please enter your phone number: ")
    state = input("Please enter your state: ")
    city = input("Please enter your city: ")
    street = input("Please enter your street: ")
    zip = input("Please enter your zip code: ")

    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('add_address', [id, phone, state, city, zip, street])
    db.commit()
    cursor.close()


def change_password(id, db):
    old_number = input("Please enter your old password: ")
    new_number = input("Please enter your new password: ")
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('change_password', [id, old_number, new_number])
    db.commit()
    cursor.close()
    print("You have changed your password!")


def search_book(book_name, db):
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('user_find_book', [book_name])
    result = cursor.fetchall()
    book_id = 0
    for element in result:
        book_id = element['bookId']
        print(element)
    db.commit()
    cursor.close()
    if book_id == 0:
        print("We cannot find this book now.")
    return book_id

def add_book_to_shoppingcart(userId, book_id, next_step, db):
    sql_stmt = "SELECT vipPrice, nonVipPrice, storageNum from storetobook where bookId = " + str(book_id) + " AND storeId = " +  str(next_step) + ";"
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.execute(sql_stmt)
    result = cursor.fetchall()
    db.commit()
    cursor.close()
    num = input("Input the num of this book that you want:")
    while int(num) > int(result[0]['storageNum']):
        print("This store cannot provide such number of this books. Please change the number or input 0 to exit")
        num = input("Input the num of this book that you want:")
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('user_add_book_to_shoppingcart', [userId, book_id, result[0]['vipPrice'], result[0]['nonVipPrice'], next_step, num])
    print("Add successful")
    db.commit()
    cursor.close()

def show_shopping_cart(userId, db):
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('show_shoppingcart', [userId])
    result1 = cursor.fetchall()
    for element in result1:
        print(element)
    db.commit()
    cursor.close()
    operation = input("If you want to change the num of book, please input 1; If you want to delete an item, please input 2; or input 3 to deal with order:")
    if int(operation) == 1:
        bookid = input("Please input the bookId that you want to change:")
        storeid = input("Please input the storeId that you want to change:")
        num = input("Please input the number that you want to change:")
        userId = int(userId)
        sql_stmt = "SELECT change_shoppingcart_num (" + str(userId) + "," + str(storeid) + "," + str(bookid) + "," + str(num) + ") AS result"
        #sql_stmt = "SELECT change_shoppingcart_num (1,2,3,3) AS result;"
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.execute(sql_stmt)
        result = cursor.fetchall()
        db.commit()
        cursor.close()
        if int(result[0]['result']) == 1:
            print("Change successful")
    elif int(operation) == 2:
        bookid = input("Please input the bookId that you want to delete:")
        storeid = input("Please input the storeId that you want to delete:")

        userId = int(userId)
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.callproc('drop_book_in_shoppingcart',[userId, storeid, bookid])
        print("Add successful")
        db.commit()
        cursor.close()
    elif int(operation) == 3:
        bookid = input("Please input the bookId that you want to place order:")
        storeid = input("Please input the storeId that you want to place order:")
        totalprice = 0
        totalnum = 0
        for element in result1:
            if int(element['bookId']) == int(bookid) and int(element['storeId']) == int(storeid):
                totalprice = element['totalPrice']
                totalnum = element['booknum']
                break
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.callproc('show_delivery_company')
        delivery_company = cursor.fetchall()
        for element in delivery_company:
            print(element)
        db.commit()
        cursor.close()
        companyid = input("Choose a delivery company, input its id:")
        delivery_fee = -1
        for element in delivery_company:  # error handling
            if element['companyId'] == companyid:
                delivery_fee = element['unitPrice']
                break
        # while True:
        #     companyid = input("Choose a delivery company, input its id:")
        #     for element in delivery_company: # error handling
        #         if element['companyId'] == companyid:
        #             delivery_fee = element['unitPrice']
        #             break
        #     if delivery_fee != -1:
        #         break
        #     else:
        #         print("Please input a valid id")
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.callproc('show_address',[userId])
        address = cursor.fetchall()
        for element in address:
            print(element)
        db.commit()
        cursor.close()
        addressid = input("Please choose an address and input its id:")
        sql_stmt = "SELECT add_book_to_order ('" + str(userId) + "','" + str(storeid) + "','" + str(bookid) + "','" + str(totalnum) + "','" + str(totalprice) + "','" + str(companyid) + "','"+ str(delivery_fee) + "','" + str(addressid) + "') AS result"
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.execute(sql_stmt)
        result = cursor.fetchall()
        db.commit()
        cursor.close()
        if int(result[0]['result']) == 1:
            print("Order successful!")

def show_order(userId, db):
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('check_status', [userId])
    result = cursor.fetchall()
    for element in result:
        print(element)
    db.commit()
    cursor.close()

def check_status(userId, db):
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('user_find_order', [userId])
    result = cursor.fetchall()
    for element in result:
        print(element) #改成仅输出部分数据，不输出bookid和storeid
    db.commit()
    cursor.close()
    next_step = input("Select an order to add comments (1) or return to menu(0)")
    if int(next_step) == 1:
        storeid = 0
        bookid = 0
        orderid = input("Please input the order id:")
        for element in result:
            if int(element['orderId']) == int(orderid):
                storeid = element['storeId']
                bookid = element['bookId']
                break
        comment = input("Please input your comment:")
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.callproc('create_comment', [userId, orderid, storeid, bookid, comment])
        db.commit()
        cursor.close()
        print("Thanks for your comments!")


def main():
    # Connect to database
    db = pymysql.connect(host='localhost',
                         user='root',
                         password="wangsc1998220",
                         db='finalproject',
                         charset='utf8mb4',
                         cursorclass=pymysql.cursors.DictCursor)

    if db:
        print("Connection Success")
        userId = 0
        choice = input("Please choose (l)login or (r)register: ")
        while choice != 'l' and choice != 'L' and choice != 'r' and choice != 'R':
            print("Please enter a valid choice")
            choice = input("Please choose (l)login or (r)register: ")

        if choice == 'l' or choice == 'L':
            userId = customer_login(db)
        elif choice == 'r' or choice == 'R':
            register(db)
            print("register success")
            print("Please login")
            userId = customer_login(db)

        while True:
            print("MENU:")
            print("1. Add delivery address")
            print("2. Change the password")
            print("3. Search books by book name")
            print("4. Show the shopping cart")
            print("5. Check the orders")
            print("6. Check the finished orders")
            print("7. Log out")
            ##print("5. Search a book by book name")
            selection = input("Please enter what you want to do: ")
            while int(selection) != 1 and int(selection) != 2 and int(selection) != 3 and int(selection) != 4 and int(selection) != 5 and int(selection) != 6 and int(selection) != 7 :
                print("Please enter a valid choice to continue!")
                selection = input("Please enter what you want to do: ")
            if int(selection) == 1:
                add_address(userId, db)
            if int(selection) == 2:
                change_password(userId, db)
            if int(selection) == 3:
                book_name = input("Please enter the book name: ")
                book_id = search_book(book_name, db)
                if book_id == 0:
                    continue
                next_step = input("Input a storeId to add the book to shopping cart or back to the menu(0)")
                if next_step == 0:
                    continue
                else:
                    add_book_to_shoppingcart(userId, book_id, next_step, db)
            if int(selection) == 4:
                show_shopping_cart(userId, db)
            if int(selection) == 5:
                show_order(userId, db)
            if int(selection) == 6:
                check_status(userId)
            if int(selection) == 7:
                cursor = db.cursor(pymysql.cursors.DictCursor)
                cursor.callproc('user_logout', [userId])
                db.commit()
                cursor.close()

        print("Thanks for using!")








    else:
        print("Connection Fail")

if __name__ == "__main__":
    main()
