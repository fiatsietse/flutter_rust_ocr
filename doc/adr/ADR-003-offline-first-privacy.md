# ADR-003 : Traitement 100% hors-ligne et Privacy-by-Design

## Contexte
Le plugin traite des documents d'identité, factures, reçus et formulaires administratifs hautement confidentiels. Aucune fuite de données vers des serveurs tiers n'est tolérable.

## Décision
1. **Absence totale de télémétrie** : Aucun tracker ou appel réseau d'analyse n'est intégré dans le SDK.
2. **Offline-First strict** : Les modèles peuvent être embarqués dans les assets ou préchargés localement.
3. **Validation SHA-256** : Tout modèle chargé depuis le stockage local est validé par empreinte cryptographique.
4. **Non-persistance** : Le plugin ne stocke aucune image sur disque sauf demande explicite de l'application cliente.

## Conséquences
- Conformité totale avec le RGPD et les réglementations internationales sur la protection des données personnelles.
- Fonctionnement garanti en zones blanches ou environnements sécurisés hors-ligne.
