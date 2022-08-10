import pymysql
from numpy.distutils.command.build import build


def register(db):
    username = input("Please enter your username: ")
    sql_stmt = "SELECT check_useful_storename('"+username+"') AS result"
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.execute(sql_stmt)

    # Username error handler
    while int(cursor.fetchall()[0]["result"]) != 1:
        print("The username is not available, please try again!")
        username = input("Please enter your username: ")
        sql_stmt = "SELECT check_useful_storename('" + username + "') AS result"
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.execute(sql_stmt)
    cursor.close()

    password = input("Please enter your password: ")
    email = input("Please enter your email: ")
    # phone = input("Please enter your phone number: ")
    # state = input("Please enter your state: ")
    # city = input("Please enter your city: ")
    # street = input("Please enter your street: ")
    # zip = input("Please enter your zip code: ")

    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('register_store', [username, password, email])
    db.commit()
    cursor.close()

def store_login(db):
    username = input("Please enter your username: ")
    password = input("Please enter your password: ")
    sql_stmt = "SELECT verify_store ('"+ username +"','"+ password +"') AS result"
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.execute(sql_stmt)

    userId = cursor.fetchall()[0]['result']

    while userId == 0:
        print("Incorrect username/password, please try again!")
        username = input("Please enter your username: ")
        password = input("Please enter your password: ")
        sql_stmt = "SELECT verify_store ('" + username + "','" + password + "') AS result"
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.execute(sql_stmt)
        userId = cursor.fetchall()[0]['result']

    print("login successful")
    return userId

def change_password(id, db):
    old_number = input("Please enter your old password: ")
    new_number = input("Please enter your new password: ")
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('change_store_password', [id, old_number, new_number])
    db.commit()
    cursor.close()
    print("You have changed your password!")

def add_book(storeId, db):
    book_name = input("Please enter the book name: ")
    cursor = db.cursor(pymysql.cursors.DictCursor)
    sql_stmt = "SELECT store_have_book('" + str(storeId) + "','" + book_name + "') AS result"
    cursor.execute(sql_stmt)
    availability = cursor.fetchall()[0]['result']
    #print(availability)
    db.commit()
    cursor.close()
    if int(availability) == 0:
        cursor = db.cursor(pymysql.cursors.DictCursor)
        vip_price = input("Please enter the vip price: ")
        normal_price = input("Please enter the normal price: ")
        storage = input("Please enter the storage number: ")
        cursor.callproc('store_add_book', [storeId, book_name, vip_price, normal_price, storage])
        db.commit()
        cursor.close()
        print("Book added success!")
    else:
        print("The book already exists, please select other operations")



def change_storage(storeId, db):
    book_name = input("Please enter the book name: ")
    storage_number = input("Please enter the storage number: ") #do not insert string, must be int
    cursor = db.cursor(pymysql.cursors.DictCursor)
    sql_stmt = "SELECT change_book_storage('" + str(storeId) + "','" + book_name + "','" + storage_number +"') AS result"
    cursor.execute(sql_stmt)
    result = cursor.fetchall()[0]['result']
    if result == 0:
        print("We cannot find this book in store. ")
    else:
        print("Changed successful!")


def change_price(storeId, db):
    book_name = input("Please enter the book name: ")
    new_vip_price = input("Please enter the new vip price: ")  # do not insert string, must be int
    new_normal_price = input("Please enter the new normal price: ")
    cursor = db.cursor(pymysql.cursors.DictCursor)
    sql_stmt = "SELECT change_book_price('" + str(storeId) + "','" + book_name + "','" + new_vip_price + "','"+ new_normal_price +"') AS result"
    cursor.execute(sql_stmt)
    result = cursor.fetchall()[0]['result']
    if result == 0:
        print("We cannot find this book in store. ")
    else:
        print("Changed successful!")

def show_book_list(storeId, db):
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('view_all_books', [storeId])
    print(cursor.fetchall())
    db.commit()
    cursor.close()

def delete_book(storeId, db):
    book_name = input("Please enter the book name: ")
    cursor = db.cursor(pymysql.cursors.DictCursor)
    sql_stmt = "SELECT store_have_book('" + str(storeId) + "','" + book_name + "') AS result"
    cursor.execute(sql_stmt)
    availability = cursor.fetchall()[0]['result']
    db.commit()
    cursor.close()
    if availability == 0:
        print("We cannot find this book so you cannot delete it.")
    else:
        cursor = db.cursor(pymysql.cursors.DictCursor)
        cursor.callproc('drop_book', [storeId, book_name])
        db.commit()
        cursor.close()
        print("Delete successful!")

def change_order_status(db):
    orderid = input("Please input the id you want to make a change: ")
    print("1.Ship")
    print("2.out for delivery")
    print("3.deliveried")
    print("4.finished")
    newStatus = input("Please choose a status from the following options(input the number): ")
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('store_change_status', [orderid, newStatus])
    db.commit()
    cursor.close()

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
        storeId = 0
        choice = input("Please choose (l)login or (r)register: ")
        while choice != 'l' and choice != 'L' and choice != 'r' and choice != 'R':
            print("Please enter a valid choice")
            choice = input("Please choose (l)login or (r)register: ")

        if choice == 'l' or choice == 'L':
            storeId = store_login(db)
        elif choice == 'r' or choice == 'R':
            register(db)
            print("register success")
            print("Please login")
            storeId = store_login(db)


        while True:
            print("MENU:")
            print("1. Change password")
            print("2. Add book")
            print("3. Change storage")
            print("4. Change price")
            print("5. Show book list")
            print("6. Delete book")
            print("7. Change the order status")
            print("8. Log out")

            selection = input("Please enter what you want to do: ")
            while int(selection) != 1 and int(selection) != 2 and int(selection) != 3 and int(selection) != 4\
                    and int(selection) != 5 and int(selection) != 6 and int(selection) != 7 and int(selection) != 8:
                print("Please enter a valid choice to continue!")
                selection = input("Please enter what you want to do: ")
            if int(selection) == 1:
                change_password(storeId, db)
            if int(selection) == 2:
                add_book(storeId, db)
            if int(selection) == 3:
                change_storage(storeId, db)
            if int(selection) == 4:
                change_price(storeId, db)
            if int(selection) == 5:
                show_book_list(storeId, db)
            if int(selection) == 6:
                delete_book (storeId, db)
            if int(selection) == 7:
                change_order_status(db)
            if int(selection) == 8:
                cursor = db.cursor(pymysql.cursors.DictCursor)
                cursor.callproc('store_logout', [storeId])
                db.commit()
                cursor.close()



    else:
        print("Connection Fail")

if __name__ == "__main__":
    main()
