<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
<html lang="fr">
	<head>
	  <meta charset="utf-8">
	  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	  <title>A qui profite la p&eacute;r&eacute;quation ?</title>
	  <meta name="description" content="">
	  <meta name="viewport" content="width=device-width">
	  <link rel="author" href="humans.txt" />
	  <meta property="fb:app_id" content="621104771250679"/>
	  <meta property="og:title" content="A qui profite la p&eacute;r&eacute;quation ?"/>
	  <meta property="og:type" content="website" />
	  <meta property="og:image" content="<?php echo $root_url; ?>/img/fb.jpg" />
	  <meta property="og:description" content="FPIC,DMTO, FSRIF : &#224; qui profite la p&#233;r&#233;quation ? Quels sont leschiffres pour votre collectivit&#233; ? Toutes les r&#233;ponses dansl'application interactive du Club Finances de la Gazette des communes." />
		{{ Asset::container('head')->styles() }}
	  {{ Asset::container('head')->scripts() }}
	  <link href='http://fonts.googleapis.com/css?family=Open+Sans:300,400,700' rel='stylesheet' type='text/css'>
	</head>
	<body>
		<div id="intro">
			<header class="main clearfix">
				<div class="container">
					<a class="title" href="/"></a>
					<div class="pull-left">
						<ul class="social">
							<li class="facebook"><div class="fb-like" data-href="<?php echo $root_url; ?>" data-send="false" data-layout="button_count" data-width="150" data-show-faces="true" data-action="recommend"></div></li>
							<li class="googleplus"><div class="g-plus" data-action="share" data-annotation="bubble"></div></li>
							<li class="twitter"><a href="https://twitter.com/share" class="twitter-share-button" data-text="A qui profite la péréquation ? Réponse dans l'application interactive du @ClubFinances #perequation" data-lang="fr" data-related="clubfinances">Tweeter</a></li>
						</ul>
					</div>
					<div class="mentions">
						<a class="btn" href="#credits">Mentions et sources</a>
					</div>
				</div>
			</header>

			<div class="content container">
				<div class="intro-text">
					<p>
						<b>Plusieurs dispositifs de p&#233;r&#233;quation horizontale, fa&#231;on Robin des bois, ont &#233;t&#233; cr&#233;&#233;s au cours des derni&#232;res ann&#233;es.<br/>
						Contrairement &#224; la p&#233;r&#233;quation verticale, op&#233;r&#233;e par les dotations allou&#233;es par l'Etat, ces m&#233;canismes pr&#233;l&#232;vent des ressources aux collectivit&#233;s consid&#233;r&#233;es riches, pour les verser aux collectivit&#233;s consid&#233;r&#233;es pauvres.</b>
					</p>
					<p>
						Si l'objectif reste &#224; chaque fois de lutter contre les in&#233;galit&#233;s, les indicateurs de mesure de la pauvret&#233; et de la richesse des territoires, utilis&#233;s par chaque dispositifs sont diff&#233;rents&#8230; P&#233;r&#233;quation des ressources du bloc communal, des droits de mutation au niveau d&#233;partemental, les dispositifs se superposent et prennent de l'ampleur, avec le risque de produire des effets contradictoires.
					</p>
					<p>
						Cette application permet de dresser un bilan de l'ensemble de ces p&#233;r&#233;quations et de faire appara&#238;tre &#224; la fois <b>les territoires b&#233;n&#233;ficiaires et les contributeurs : les premiers sont-ils bien les plus pauvres ? Les second sont-ils r&#233;ellement les plus riches ?</b> Les diff&#233;rents syst&#232;mes n'ont-ils pas tendance &#224; se neutraliser ?
					</p>
					<p>
						Pour r&#233;pondre &#224; ces questions, nous avons agr&#233;g&#233; les diff&#233;rents flux des p&#233;r&#233;quations 2012 pour offrir un point de vue &#224; l'&#233;chelle r&#233;gionale, d&#233;partementale et intercommunale. L'application permet &#233;galement de comparer les collectivit&#233;s et les intercommunalit&#233;s entre elles, pour mesurer la coh&#233;rence des dispositifs. Elle sera compl&#233;t&#233;e, prochainement, des flux de la p&#233;r&#233;quation sur la contribution sur la valeur ajout&#233;e des entreprises.
					</p>
					<p>
						NB : les montants per&#231;us ou vers&#233;s au titre du fonds de solidarit&#233; de la r&#233;gion &#206;le-de-France ont &#233;t&#233; ajout&#233;s au montant per&#231;us ou vers&#233;s au titre du FPIC.
					</p>
				</div>
				<!--[if lt IE 9]>
      		<p class="chromeframe">Votre navigateur est trop ancien et ne dispose pas des technologies n&#233;cessaires pour naviguer au sein de cette application.<br/>
      		Vous pouvez <a href="http://www.google.com/chromeframe/?redirect=true">installer simplement Google Chrome Frame</a> pour am&#233;liorer votre exp&#233;rience (droits administrateur non requis).</p>
	  		<![endif]-->
				<div class="intro-launch">
					<a id="launch-button" class="btn btn-large" href="<?php echo $root_url; ?>/donnees/toutes/france">Lancer l&rsquo;application</a>
				</div>
				<!--[if lt IE 9]>
					<script>document.getElementById("launch-button").style.display="none";</script>
	  		<![endif]-->

			</div>

			<div id="fb-root"></div>

			<div class="mentions-popup">
				<div class="text-content">
					<a href="https://github.com/AngryKatze/a-qui-profite-la-perequation" target="_blank"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png" alt="Fork me on GitHub"></a>
					<a href="#" class="close">x</a>
					<h2>Mentions et sources</h2>

					<h3>Sources et calculs</h3>
					<p>
						Cette application a &#233;t&#233; r&#233;alis&#233;e avec les donn&#233;es 2012 issues de la Direction g&#233;n&#233;rale des collectivit&#233;s locales.<br/>
						Pour les communes d'Ile-de-France, les donn&#233;es du FSRIF ont &#233;t&#233; ajout&#233;es aux donn&#233;es FPIC pour l'intercommunalit&#233; de r&#233;f&#233;rence.
					</p>
					<p>Le revenu par habitant a &#233;t&#233; obtenu en divisant le revenu de la collectivit&#233; par sa population Insee. Le revenu par habitant moyen a &#233;t&#233; calcul&#233; de la m&#234;me fa&#231;on, sur l'ensemble des collectivit&#233;s mentionn&#233;es dans l'application. Pour les intercommunalit&#233;s, le potentiel fiscal retenu est le potentiel fiscal 4 taxes calcul&#233; de la DGF.</p>
					<p>Pour quelques collectivit&#233;s, certaines donn&#233;es (population ou potentiel fiscal) n'&#233;taient pas disponibles, elles ne sont donc pas mentionn&#233;es dans l'application.</p>

					<h3>Conception de l’application</h3>
					<ul>
						<li>La Gazette des communes :
							<ul>
								<li>Romain Mazon <a href="https://twitter.com/romainmazon" target="_blank"><i class="icon-circle-arrow-right"></i> @romainmazon</a></li>
								<li>Jacques Paquier <a href="https://twitter.com/JacquesPaquier" target="_blank"><i class="icon-circle-arrow-right"></i> @JacquesPaquier</a></li>
								<li>Rapha&#235;l Richard <a href="https://twitter.com/ClubFinances" target="_blank"><i class="icon-circle-arrow-right"></i> @ClubFinances</a></li>
							</ul>
						</li>
						<li>Marie Coussin <a href="https://twitter.com/MarieCoussin" target="_blank"><i class="icon-circle-arrow-right"></i> @MarieCoussin</a></li>
						<li><a href="https://plus.google.com/112175203876678292551" rel="publisher" target="_blank" class="authorship">AngryKatze</a> - James Lafa <a href="http://www.angrykatze.com" target="_blank"><i class="icon-circle-arrow-right"></i> www.angrykatze.com</a></li>
					</ul>

					<h3>Traitement des donn&#233;es et gestion de projet</h3>
					<ul>
						<li>Marie Coussin <a href="https://twitter.com/MarieCoussin" target="_blank"><i class="icon-circle-arrow-right"></i> @MarieCoussin</a></li>
					</ul>

					<h3>Design de l'application</h3>
					<ul>
						<li>Marion Boucharlat <a href="http://www.marion-boucharlat.com" target="_blank"><i class="icon-circle-arrow-right"></i> www.marion-boucharlat.com</a></li>
					</ul>

					<h3>D&#233;veloppement de l'application</h3>
					<ul>
						<li><a href="https://plus.google.com/112175203876678292551" rel="publisher" target="_blank" class="authorship">AngryKatze</a> - James Lafa <a href="http://www.angrykatze.com" target="_blank"><i class="icon-circle-arrow-right"></i> www.angrykatze.com</a></li>
					</ul>

					<h3>Open-source</h3>
					<p>La Gazette des communes et AngryKatze ont fait le choix de mettre &#224; disposition le code source de l'application ainsi que les donn&#233;es utilis&#233;es sous licence libre. Tout est disponible sur <a href="https://github.com/AngryKatze/a-qui-profite-la-perequation" target="_blank">Github</a>.</p>
				</div>
			</div>
			<footer class="main container">
				<a class="club-finance" href="http://www.lagazettedescommunes.com/rubriques/club-finances/" target="_blank"><img src="<?php echo $root_url; ?>/img/club_finance.jpg" alt="Club finance"/></a>
				{{ Asset::container('footer')->scripts() }}

		    <script>
				  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
				  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
				  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
				  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

				  ga('create', 'UA-40757740-1', 'angrykatze.com');
				  ga('send', 'pageview');
				</script>

				<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
				<script>(function(d, s, id) {
					  var js, fjs = d.getElementsByTagName(s)[0];
					  if (d.getElementById(id)) return;
					  js = d.createElement(s); js.id = id;
					  js.src = "//connect.facebook.net/fr_FR/all.js#xfbml=1&appId=621104771250679";
					  fjs.parentNode.insertBefore(js, fjs);
					}(document, 'script', 'facebook-jssdk'));
				</script>
				<script type="text/javascript">
				  window.___gcfg = {lang: 'fr'};
				  (function() {
				    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
				    po.src = 'https://apis.google.com/js/plusone.js';
				    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
				  })();
				</script>
			</footer>

		</div>
	</body>
</html>
