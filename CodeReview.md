###Code Review###

J'aime :
- Utilisation de SPM
- Projet organise, on comprend vite ou sont les fichiers. Pour un petit projet simple ca suffit amplement :)
- On voit que tu as fait des effort sur l'encapsulation. Ca peut etre ameliorer encore. Il reste par ex des properties de tes VM avec leur get set en acces libre.
- Le pattern input/output pour le VM+ VC. Par contre il pourrait etre encore ameliorer en passant par les init des viewController et donc delete les storyboard
- La gestion des erreurs. C'est rarement fait et c'est une tres bonne habitude de les handle avec un message d'erreur
- Utilisation du try catch avec des methodes qui throw
- L'injection de tes services dans les viewModel
- L'utilisation de protocols pour tes services et du type abstrait dans tes VM
- Le code est plutot bien indente c'est propre


J'aime moins :
- Je n'ai pas trouve de tests unitaires ? Si tu devais en ajouter qu'est ce que tu testerais en premier ? Pourquoi ?
- Toutes tes classes qui ne sont pas heritées et/ou vouées a faire de l'heritage devraient avoir le mot cle `final`. Eg: `final class Toto`
- Les stoyboard.
- Le naming du folder `View+ViewModel`: Il possde des VC des storyboard.. Disons que ce nommage est bien pour un petit projet mais pas pour un grand projet. Tu as ensuites bien nomme les sub folder cad Profile, Login, etc. qui sont finalement les features de ton app. Pourquoi ne pas donc renommer ton folder en Features ? C'est une idee ;)
- Folder User avec juste un VM dedans, il sert a quelle vue ?
- Pourquoi Profile n'a pas de VM ?
- Ton model User est codable. Dans une app simple ok. Pour scaler il faut eviter. Un model est normalement un objet "Business" et donc pas codable (Tech). Le mieux est d'avoir un objet tech (DTO) qui va etre converti en model business.
- Presence de quelques implicit unwrap. J'essaie d'en avoir aucun sur mes apps car implicit unwrap signifie un crash de l'app potentiel
- La navigation dans les ViewControllers, pas de router, coordinator ou autre pattern de navigation. A savoir que storyboard et coordinator sont compatibles
- Pas de linter comme SwiftLint: habitude a avoir pour ameliorer la qualite du code. Surtout quand on est junior ca aide a avoir du code propre.

Les ?:
- Pourquoi on a le package Promises ? Ca vient d'une de tes dependences ou c'est toi qui l'a ajoute ?
- Pourquoi tes services sont des classes ? A quoi ca sert de les init ?
- Pourquoi avoir utilise des storyboard pour la UI ?
- Quels seraient les inconvenients des storyboard selon toi ? Les avantages ?
- Sais-tu implementer une vue en UIKit que par le code ? (sans storyboard)


Conclusion:
Le projet est plutot bien pour un niveau de junior donc bravo a toi. Il ne faut pas que tu laches, tu vas trouver ;)
Axe d'amelioration serait de le faire en SwiftUI. Aujourd'hui toutes les boites presques ont au moins fait 1 vue en SwiftUI, le passage est en train de se faire. Le best est encore UIKit donc tres bien que tu saches en faire. Essaie de te passer des storyboard a mon sens et de voir le pattern Coordinator. Et si t'es curieux et que tu as du temps lis le livre Clean Architecture de Martin C. Tu vas mieux comprendre ce qu'est du code tech et business et view et mieux architecturer des apps complexes.
