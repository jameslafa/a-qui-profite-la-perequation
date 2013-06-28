#A qui profite la péréquation

**A collaborative work from**

 - [Marie Coussin][1] : Data Journalist and Project Manager
 - [Marion Boucharlat][2] : Designer
 - [James Lafa][3] [[AngryKatze][4]] : Web Developer

**Based on an idea of our client** [La Gazette Des Communes][5]

 - [Romain Mazon][6] : Chief editor web
 - [Jacques Paquier][7] : Club Finances Editor
 - [Raphaël Richard][8] : Journalist at Club Finances

The application is available [here][9].

### Requirements ###

The backend API use [Laravel framework][10]. The requirements are:

 - PHP 5.3.x with library [mcrypt activated][11]
 - MySQL 5.x (it should work with other databases, but we only tested MySQL)

### Configuration ###

#### Database configuration ####

 - Update database configuration in `application/config/database`
 - Create a new database. Default configuration is `perequations`
 - Import into database the last `*-perequations.sql` file of the directory `data/database`

#### Cache configuration ####

By default, cache system uses the filesystem. Web server must have write access to the directory `storage/cache`

If you update data into the database, don't forget to update the cache directory.

#### Optimization ####

Don't forget to activate gzip compression on the web server. Api sends lots of data so it will increase app performance.

### Licence ###

La Gazette Des Communes, AngryKatze and Marie Coussin generously share their work to help the community.

#### Source code ####

The source code is available on this repository under licence [GNU GENERAL PUBLIC LICENSE v3][12] (translation in multiple language is available on the website). We share the code of this application to help other media and developers to learn how to do such data visualisation. You can read, modify, distribute our code if you keep your code open-source as well.

You'll find the data visualisation code in `application/assets/coffee/main.coffee` and API code in `bundles/api`.

#### Data ####

Data computed by Marie Coussin are also available on the repository in 3 different formats in `data/database`.

 - **Publication date** : 27/06/2013
 - **Source** : Directon générale des collectivités locales
 - **Temporal coverage** : 2012
 - **Update frequency** : Annual
 - **Licence** : [Open Database License (ODbL) v1.0][13] [[summary][14]]
 - **Language** : French (see `data-description.txt` for translation)
 - **Geographic coverage** : Metropolitan France
 - **Files format** : csv, sql, ods

The complete file description is available in `data/database/data-description.txt`.

If you use our code or data, we'll be happy to here about it so please ping us on twitter !

If you have any question, please contact us on twitter [@AngryKatze][15]


  [1]: https://twitter.com/MarieCoussin
  [2]: http://www.marion-boucharlat.com/
  [3]: https://twitter.com/jameslafa
  [4]: http://www.angrykatze.com/
  [5]: http://www.lagazettedescommunes.com/
  [6]: https://twitter.com/romainmazon
  [7]: https://twitter.com/JacquesPaquier
  [8]: https://twitter.com/ClubFinances
  [9]: http://app.lagazettedescommunes.com/gazette-perequations/public/
  [10]: http://laravel.com/
  [11]: http://www.php.net/manual/en/mcrypt.installation.php
  [12]: http://www.gnu.org/licenses/gpl-3.0.en.html
  [13]: http://opendatacommons.org/licenses/odbl/1-0/
  [14]: http://opendatacommons.org/licenses/odbl/summary/
  [15]: https://twitter.com/AngryKatze