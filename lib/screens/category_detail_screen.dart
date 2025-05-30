// lib/category_detail_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // Pour des couleurs aléatoires si besoin

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailScreen({Key? key, required this.categoryName}) : super(key: key);

  Map<String, dynamic> _getCategoryDetails(String name) {
    switch (name) {
      case 'Plastic':
        return {
          'description': "Le plastique est un matériau synthétique largement utilisé, mais son recyclage est crucial pour réduire la pollution. Agir pour réduire son impact est essentiel pour notre planète.",
          'whatToDo': "- Rincez les contenants.\n- Séparez les bouchons si les consignes locales l'exigent.\n- Aplatissez les bouteilles pour gagner de la place.",
          'whereToThrow': "- Bac de tri sélectif (souvent jaune).\n- Points d'apport volontaire spécifiques pour certains types de plastiques.",
          'tips': "- Privilégiez les emballages réutilisables.\n- Vérifiez les numéros de recyclage (♻️1 à ♻️7).\n- Évitez les plastiques à usage unique autant que possible.",
          'recyclingCompanies': "- Citeo (France)\n- Veolia\n- Suez\n- Paprec",
          'recyclingTools': "- Broyeurs industriels\n- Extrudeuses pour refondre le plastique\n- Presses à balles",
          'exampleSearchTerms': [
            'plastic bottle waste',
            'plastic shopping bag',
            'yogurt pot empty',
            'plastic straw pollution',
            'shampoo bottle empty'
          ],
        };
      case 'Glass':
        return {
          'description': "Le verre est 100% recyclable et à l'infini sans perte de qualité ou de pureté. Son recyclage économise beaucoup d'énergie.",
          'whatToDo': "- Videz et rincez sommairement les bouteilles, pots et bocaux en verre.\n- Inutile de retirer les étiquettes.\n- Séparez les couvercles (métal ou plastique).",
          'whereToThrow': "- Conteneurs à verre spécifiques (généralement verts ou blancs).\n- Ne pas y mettre : vaisselle cassée, porcelaine, faïence, ampoules.",
          'tips': "- Le verre coloré et le verre transparent sont généralement collectés ensemble ou séparément selon les communes.\n- Soyez prudent avec le verre cassé.",
          'recyclingCompanies': "- Verallia\n- O-I Glass\n- SGD Pharma\n- Ardagh Group",
          'recyclingTools': "- Concasseurs de verre\n- Fours de fusion à haute température\n- Calcin (verre broyé)",
          'exampleSearchTerms': [
            'empty wine bottle',
            'glass jar food',
            'broken beer bottle',
            'perfume bottle empty',
            'glass cup'
          ],
        };
      case 'Metal':
        return {
          'description': "Les métaux comme l'acier et l'aluminium sont très bien recyclés et peuvent l'être indéfiniment, économisant ressources et énergie.",
          'whatToDo': "- Videz bien les boîtes de conserve, canettes, aérosols.\n- Il n'est généralement pas nécessaire de les laver, mais ils ne doivent pas contenir de restes importants.",
          'whereToThrow': "- Bac de tri sélectif (souvent jaune).\n- Déchetteries pour les objets métalliques plus volumineux ou spécifiques.",
          'tips': "- L'aluminium est particulièrement précieux à recycler.\n- Les petits objets en métal (capsules, couvercles) peuvent parfois être mis dans une boîte de conserve vide pour éviter qu'ils se perdent.",
          'recyclingCompanies': "- ArcelorMittal\n- Constellium (Aluminium)\n- Derichebourg\n- Nucor",
          'recyclingTools': "- Aimants géants (pour l'acier)\n- Courants de Foucault (pour l'aluminium)\n- Cisailles et broyeurs à métaux\n- Fours de fusion",
          'exampleSearchTerms': [
            'tin can food',
            'aluminum soda can',
            'empty aerosol can',
            'metal bottle cap',
            'old metal pan'
          ],
        };
      case 'Carton': // Cardboard
        return {
          'description': "Le carton, fabriqué à partir de fibres de cellulose, est facilement recyclable. Il est crucial de le garder propre et sec.",
          'whatToDo': "- Aplatissez les boîtes en carton pour économiser de l'espace.\n- Retirez les gros scotchs ou éléments plastiques si possible.\n- Ne pas jeter de carton souillé par de la nourriture (ex: boîte à pizza très grasse).",
          'whereToThrow': "- Bac de tri sélectif (souvent bleu ou jaune, selon les communes).\n- Déchetteries pour les grandes quantités.",
          'tips': "- Le carton ondulé et le carton plat sont recyclables.\n- Les briques alimentaires (lait, jus) sont souvent recyclables avec le carton mais vérifiez les consignes locales spécifiques.",
          'recyclingCompanies': "- Smurfit Kappa\n- DS Smith\n- International Paper\n- WestRock",
          'recyclingTools': "- Pulpeurs pour décomposer le carton en fibres\n- Presses à balles pour compacter\n- Machines à papier recyclé",
          'exampleSearchTerms': [
            'cardboard box packaging',
            'cereal box empty',
            'shipping box',
            'egg carton',
            'paperboard'
          ],
        };
      case 'Paper':
        return {
          'description': "Le papier est l'un des matériaux les plus recyclés. Son recyclage permet de préserver les forêts et d'économiser de l'eau et de l'énergie.",
          'whatToDo': "- Ne pas froisser le papier en boule compacte, mais le laisser à plat ou le déchirer.\n- Retirer les spirales métalliques ou plastiques des cahiers si possible.",
          'whereToThrow': "- Bac de tri sélectif (souvent bleu ou jaune).\n- Points d'apport volontaire dédiés.",
          'tips': "- Tous les papiers ne sont pas recyclables (ex: papier photo, papier sulfurisé, mouchoirs usagés, papier thermique de caisse).\n- Imprimez recto-verso pour économiser le papier.",
          'recyclingCompanies': "- UPM\n- Stora Enso\n- Norske Skog\n- Resolute Forest Products",
          'recyclingTools': "- Pulpeurs pour transformer en pâte à papier\n- Machines de désencrage\n- Machines à papier",
          'exampleSearchTerms': [
            'newspaper pile',
            'office paper stack',
            'magazine old',
            'junk mail envelope',
            'notebook paper'
          ],
        };
      case 'Others': // Catégorie "Autres"
        return {
          'description': "La catégorie 'Autres' regroupe des déchets spécifiques qui ne rentrent pas dans les filières classiques ou qui nécessitent un traitement particulier.",
          'whatToDo': "- Identifiez précisément le type de déchet.\n- Renseignez-vous sur les points de collecte spécifiques (déchetteries, magasins, associations).\n- Ne mélangez pas ces déchets avec les ordures ménagères classiques.",
          'whereToThrow': "- Déchetteries (piles, batteries, huiles, produits chimiques, déchets électroniques).\n- Points de collecte en magasin (ampoules, médicaments non utilisés en pharmacie).\n- Bornes spécifiques (vêtements, jouets).",
          'tips': "- Les déchets dangereux doivent être manipulés avec précaution.\n- Beaucoup d'objets peuvent être réparés ou donnés avant d'être considérés comme déchets.\n- La réduction à la source est la meilleure solution.",
          'recyclingCompanies': "- Varie énormément selon le type de déchet (ex: Eco-systèmes pour DEEE, Corepile pour piles).\n- Associations caritatives pour textiles.",
          'recyclingTools': "- Processus de démantèlement spécifiques (DEEE).\n- Traitements chimiques contrôlés (déchets dangereux).\n- Centres de tri spécialisés.",
          'exampleSearchTerms': [
            'old battery',
            'used light bulb',
            'electronic waste e-waste',
            'old clothes donation',
            'expired medicine'
          ],
        };
      default:
        return {
          'description': "Découvrez comment bien gérer cette catégorie pour un impact positif sur l'environnement.",
          'whatToDo': "Informations à venir.",
          'whereToThrow': "Informations à venir.",
          'tips': "Informations à venir.",
          'recyclingCompanies': "Informations à venir.",
          'recyclingTools': "Informations à venir.",
          'exampleImages': [
            '       lib/images/bottles.png',
            'lib/images/plasticbag.png',
            'lib/images/yougurtpot.png',
          ],
        };
    }
  }

  // Widget pour une section d'information stylisée (peut être une carte ou autre)
  Widget _buildInfoBlock({
    required BuildContext context,
    required IconData iconData,
    required String title,
    required String content,
    required Color backgroundColor, // Couleur de fond du bloc
    required Color iconAndTextColor, // Couleur pour l'icône et le titre
    double? width, // Largeur optionnelle
    double height = 180.0, // Hauteur fixe pour une certaine uniformité
  }) {
    return Container(
      width: width, // Si null, prendra la largeur disponible dans une Row/Column
      height: height,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrer le contenu verticalement
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, color: iconAndTextColor, size: 30.0),
              const SizedBox(width: 8.0),
              Flexible( // Pour que le texte du titre ne déborde pas
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17, // Un peu plus petit pour les blocs compacts
                    fontWeight: FontWeight.bold,
                    color: iconAndTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Expanded( // Pour que le contenu prenne l'espace restant et puisse scroller si besoin
            child: SingleChildScrollView( // Au cas où le contenu est trop long pour la hauteur fixe
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: iconAndTextColor.withOpacity(0.85),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = _getCategoryDetails(categoryName);
    final Color primaryThemeColor = Theme.of(context).colorScheme.primary;
    final Color secondaryThemeColor = Theme.of(context).colorScheme.secondary;

    // Couleurs pour les blocs - à personnaliser pour plus de créativité
    // Vous pouvez créer une liste de paires de couleurs (fond, texte/icône)
    final List<Map<String, Color>> blockColors = [
      {'bg': Colors.teal[50]!, 'text': Colors.teal[700]!},
      {'bg': Colors.amber[50]!, 'text': Colors.amber[800]!},
      {'bg': Colors.lightBlue[50]!, 'text': Colors.lightBlue[700]!},
      {'bg': Colors.pink[50]!, 'text': Colors.pink[600]!},
      {'bg': Colors.green[50]!, 'text': Colors.green[700]!},
    ];
    int colorIndex = 0;
    Map<String, Color> nextColor() {
      final color = blockColors[colorIndex % blockColors.length];
      colorIndex++;
      return color;
    }


    return Scaffold(
      backgroundColor: Colors.white, // Fond de la page
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryThemeColor),
        ),
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0, // Pas d'ombre
        iconTheme: IconThemeData(color: primaryThemeColor), // Couleur de l'icône de retour
      ),
      body: CustomScrollView( // Permet des éléments plus complexes qu'un SingleChildScrollView
        slivers: <Widget>[
          // Section Description (sans carte, proéminente)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              margin: const EdgeInsets.only(bottom: 20.0, left: 16, right: 16),
              decoration: BoxDecoration(
                color: primaryThemeColor.withOpacity(0.1), // Un fond subtil pour la description
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Zoom sur : $categoryName",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryThemeColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details['description']!,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reste des informations en utilisant _buildInfoBlock
          // On peut les agencer en Row ou les laisser en Column
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding pour les blocs suivants
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBlock(
                        context: context,
                        iconData: Icons.rule_folder_outlined,
                        title: 'Que faire ?',
                        content: details['whatToDo']!,
                        backgroundColor: nextColor()['bg']!,
                        iconAndTextColor: nextColor()['text']!,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoBlock(
                        context: context,
                        iconData: Icons.recycling_outlined,
                        title: 'Où jeter ?',
                        content: details['whereToThrow']!,
                        backgroundColor: nextColor()['bg']!,
                        iconAndTextColor: nextColor()['text']!,
                      ),
                    ),
                  ],
                ),
                _buildInfoBlock( // Ce bloc prendra toute la largeur
                  context: context,
                  iconData: Icons.tips_and_updates_outlined,
                  title: 'Conseils & Astuces',
                  content: details['tips']!,
                  backgroundColor: nextColor()['bg']!,
                  iconAndTextColor: nextColor()['text']!,
                  height: 220, // Un peu plus haut pour plus de contenu
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBlock(
                        context: context,
                        iconData: Icons.business_outlined,
                        title: 'Sociétés',
                        content: details['recyclingCompanies']!,
                        backgroundColor: nextColor()['bg']!,
                        iconAndTextColor: nextColor()['text']!,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoBlock(
                        context: context,
                        iconData: Icons.construction_outlined,
                        title: 'Outils',
                        content: details['recyclingTools']!,
                        backgroundColor: nextColor()['bg']!,
                        iconAndTextColor: nextColor()['text']!,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20), // Espace en bas
              ]),
            ),
          ),
        ],
      ),
    );
  }
}