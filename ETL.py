import requests
import urllib.parse
import boto3
from pyspark.sql import SparkSession
import pandas as pd

def main():
    # Configuración de Spark
    spark = SparkSession.builder \
        .appName("ClashOfClansData") \
        .getOrCreate()

    # Reemplaza con tu propia API Key de Clash of Clans
    API_KEY = 'tu_api_key'  # Debes almacenar esta clave de forma segura, quizás en AWS Secrets Manager
    BASE_URL = 'https://api.clashofclans.com/v1/'
    HEADERS = {'Authorization': f'Bearer {API_KEY}'}
    
    # Lista de ID de clanes a los que deseas acceder
    CLAN_TAGS = ['#9Y8CQ9J8']

    def fetch_clan_data(clan_tag):
        encoded_clan_tag = urllib.parse.quote(clan_tag)
        response = requests.get(f'{BASE_URL}clans/{encoded_clan_tag}', headers=HEADERS)
        response.raise_for_status()
        return response.json()

    # Inicializar listas para almacenar datos
    data = []

    for clan_tag in CLAN_TAGS:
        try:
            clan_data = fetch_clan_data(clan_tag)
            members = clan_data.get('memberList', [])
            for member in members:
                data.append({
                    'Clan Name': clan_data['name'],
                    'Player Name': member['name'],
                    'Player Tag': member['tag'],
                    'Player Level': member['expLevel'],
                    'Player Trophy Count': member['trophies'],
                    'Player Donations': member['donations'],
                    'Player Donations Received': member['donationsReceived'],
                    'Player League': member['league']['name'],
                    'Clan Rank': member['clanRank'],
                    'Previous Clan Rank': member['previousClanRank']
                })
        except Exception as e:
            print(f"Error al obtener datos para el clan {clan_tag}: {e}")

    # Convertir a DataFrame de Spark
    df = spark.createDataFrame(data)
    
    # Configuración de S3
    s3_client = boto3.client('s3')
    processed_bucket = 'coc-etl-processed-data'
    output_path = "s3://coc-etl-processed-data/processed_data/clash_of_clans_data/"
    
    # Guardar en JSON
    temp_file_path = "/tmp/clash_of_clans_data.json"  # Ruta temporal en el sistema local
    df.write.mode("overwrite").json(temp_file_path, mode="overwrite")
    
    # Subir archivo JSON a S3
    s3_client.upload_file(temp_file_path, processed_bucket, "processed_data/clash_of_clans_data/clash_of_clans_data.json")

if __name__ == "__main__":
    main()
