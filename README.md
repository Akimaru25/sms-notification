# Script d’envoi de notifications SMS via SOAP

## 📌 Contexte

Ce script a été développé dans le cadre de mon alternance en tant qu’administrateur système et réseaux. Il a pour objectif de **notifier automatiquement par SMS** certains événements de supervision (états d’hôtes) via un service SOAP interne.

## ⚙️ Fonctionnement

Le script utilise `Perl`, la bibliothèque `LWP::UserAgent`, et traite les paramètres passés en ligne de commande pour construire et envoyer une requête SOAP vers un serveur d’envoi de SMS.

### Étapes principales :
1. **Récupération des paramètres** : Nom de l’hôte, état, message, type de notification, etc.
2. **Filtrage** des notifications non pertinentes (par ex. `FLAPPINGSTART`, `FLAPPINGEND`).
3. **Construction du message** au format texte avec sauts de ligne HTML (`&#13;&#10;`).
4. **Envoi du message** via une requête SOAP POST vers un service spécifique (`/service.xml`).
5. **Affichage du résultat** : ID de file de traitement reçu ou message d’erreur.

## 🧪 Exemple d’utilisation

```bash
perl send_sms.pl -H 192.168.1.1 -D 0600000000 -d "2025-06-06 12:00" \
-l SRV-NAGIOS -n "Serveur Nagios" -s DOWN -o "Host unreachable" \
-t PROBLEM -b "admin" -c "Vérification en cours"
