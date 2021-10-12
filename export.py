import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import storage
import mysql.connector
import time
import os

districts = [
    {'id': 5, 'title': 'Алмазар'}, 
    {'id': 15, 'title': 'Бектемир'},
    {'id': 25, 'title': 'Мирабад'},
    {'id': 35, 'title': 'Мирзо-Улугбек'},
    {'id': 45, 'title': 'Центр'},
    {'id': 55, 'title': 'Сергели'},
    {'id': 65, 'title': 'Чиланзар'},
    {'id': 75, 'title': 'Шайхантаур'},
    {'id': 85, 'title': 'Юнусабад'},
    {'id': 95, 'title': 'Яккасарай'},
    {'id': 105, 'title': 'Яшнабад'},
]


creds = credentials.Certificate('firebase-token.json')
app = firebase_admin.initialize_app(credential=creds, options={'storageBucket': 'eventflats.appspot.com'})
db = firestore.client()
bucket = storage.bucket()
storage.storage.Blob
mysql_db = mysql.connector.connect(
    host='us-cdbr-east-04.cleardb.com', # us-cdbr-east-04.cleardb.com
    user='bfeaae7c0f4969', # bfeaae7c0f4969
    password='7b5ac5b7', # 7b5ac5b7 
    database='heroku_15dec8607958c07') # heroku_15dec8607958c07

cursor = mysql_db.cursor()
select_cursor = mysql_db.cursor()

doc_ref = db.collection('flats')
docs = doc_ref.stream()

landmark_sql = 'SELECT id FROM landmarks WHERE title = %s'
select_cursor.execute(landmark_sql, ('Test',))
landmark = select_cursor.fetchone()

for doc in docs:
    print(f'Start insertings {doc.id}...')
    flat = doc.to_dict()
    district = list(filter(lambda d: d['title'] == flat['address'], districts))
    district_id = district[0]['id']
    landmark_id = None
    if flat['landmark'] != '':
        landmark_sql = 'SELECT id FROM landmarks WHERE title = %s'
        select_cursor.execute(landmark_sql, (flat['landmark'],))
        landmark = select_cursor.fetchone()
        if not landmark:
            cursor.execute('INSERT INTO landmarks (title, district_id) VALUES (%s, %s)', (flat['landmark'], district_id))
            mysql_db.commit()
            landmark_id = cursor.lastrowid
            print(f'Inserted ${flat["landmark"]} to ${district_id}')
    values = (flat['area'], flat['description'], flat['flatRepair'], flat['floor'], flat['numberOfFloors'], flat['numberOfRooms'], flat['price'], '["'+flat['ownerPhone']+'"]', flat['ownerName'], district_id, landmark_id, 5, flat['createdAt'], flat['createdAt'])
    sql = 'INSERT INTO flats (area, note, repair, floor, floors_number, rooms_number, price, phones, owner_name, district_id, landmark_id, creator_id, created_at, updated_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)'
    cursor.execute(sql, values)
    mysql_db.commit()
    image = bucket.blob(f'flats/{doc.id}')
    if image.exists():
        filename = doc.id + '.jpg'
        image.download_to_filename(filename)
        current_time = time.time() * 10000
        moved_image = bucket.blob(f'flats/{cursor.lastrowid}/{current_time}.jpg')
        moved_image.upload_from_filename(filename)
        print('Uploaded image for ' + doc.id)
        os.remove(filename)
    print('Done')
