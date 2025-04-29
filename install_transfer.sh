#!/data/data/com.termux/files/usr/bin/bash

# Mise à jour et installation
pkg update && pkg upgrade -y
pkg install python git -y
pip install telethon

# Création du script Python
cat > telegram_transfer.py << 'EOF'
import asyncio
from telethon.sync import TelegramClient
from telethon.tl.functions.channels import InviteToChannelRequest

api_id = int(input("Entrez votre API ID: "))
api_hash = input("Entrez votre API HASH: ")
phone_number = input("Entrez votre numéro de téléphone (+XXX...): ")
source_group = input("Lien ou @ du groupe source: ")
destination_group = input("Lien ou @ du groupe destination: ")

limit = 25

client = TelegramClient('session_name', api_id, api_hash)

async def main():
    await client.start(phone=phone_number)
    print("Connecté.")

    source = await client.get_entity(source_group)
    destination = await client.get_entity(destination_group)

    print("Récupération des membres...")
    source_members = await client.get_participants(source, limit=limit)
    dest_members = await client.get_participants(destination)

    dest_ids = {user.id for user in dest_members}

    count = 0
    for user in source_members:
        if user.id not in dest_ids and not user.bot:
            try:
                await client(InviteToChannelRequest(destination, [user]))
                print(f"{user.first_name} ajouté.")
                count += 1
                await asyncio.sleep(10)
            except Exception as e:
                print(f"Erreur : {e}")
                await asyncio.sleep(5)

    print("Ajout terminé.")

with client:
    client.loop.run_until_complete(main())
EOF

# Lancement
python telegram_transfer.py
