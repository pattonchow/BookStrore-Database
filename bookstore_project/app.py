from flask import Flask, render_template, request, redirect,url_for
import pymysql

db = pymysql.connect(host='localhost',
                       user='root',
                       password="20101001aA!",
                       db='finalproject',
                       charset='utf8mb4',
                       cursorclass=pymysql.cursors.DictCursor)

app = Flask("Bookstore")

app = Flask(__name__)

#customer register
def customer_register(username,password,email,phone,state,city,zip,street):
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('register', (username,password,email,phone,state,city,zip,street))
    db.commit()

#customer searchbook
def customer_search_book(book_name):
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.callproc('user_find_book', [book_name])
    return cursor.fetchone()
    db.commit()

#test
# def query_single_data_Name(bookName):
#     sql = f"""SELECT * FROM book
#     where bookName = '{bookName}'"""
#     cursor = db.cursor(pymysql.cursors.DictCursor)
#     cursor.execute(sql)
#     return cursor.fetchone()


# verify user account accessable
def verify_customer(username,password):
    sql_stmt = "SELECT verify('"+ username +"', '"+ password +"') AS result"
    cursor = db.cursor(pymysql.cursors.DictCursor)
    cursor.execute(sql_stmt)
    return cursor.fetchall()

@app.route("/customerRegister", methods=["post","get"])
def customerRegister():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        email = request.form.get("email")
        phone = request.form.get("phone")
        state = request.form.get("state")
        city = request.form.get("city")
        zip = request.form.get("zip")
        street = request.form.get("street")
        customer_register(username, password, email, phone, state, city, zip, street)
        return render_template("customerindex.html")
    return render_template("customerRegister.html")

@app.route("/checkusername", methods=["post"])
def checkusername():
    if request.method == "POST":
        username = request.form.get("username")

@app.route('/customerlogin', methods=["post","get"])
def customerLogin():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        result = verify_customer(username,password)
        print(result[0]['result'])
        if (result[0]['result'] == 0):
            return redirect('/customerRegister')
        else:
            return render_template("customerindex.html")


    return render_template("customerLogin.html")

@app.route('/customerSearch',methods=["GET","POST"])
def customerSearch():
    result = ""
    if request.method == "POST":
        book_name = request.form.get("bookName")
        result = customer_search_book(book_name)
        # req = query_single_data_Name(book_name)
        print(result)
        # print(req)
        # result = "search result"
        return render_template("customerSearch.html", result=result)
    return render_template("customerIndex.html")

# @app.route('/addChart', methods=["GET", "POST"])
# def addChart():
#     if request.method == "POST":
#


@app.route('/')
def hello_world():
    return render_template("index.html")



if __name__ == '__main__':
    app.run(debug=True)
