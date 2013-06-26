<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
<html lang="fr">
	<head>
	  <meta charset="utf-8">
	  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	  <title><?php echo $title; ?></title>
	  <meta name="description" content="">
	  <meta name="viewport" content="width=device-width">
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
		<div id="app">
			<header class="main clearfix">
				<div class="container">
					<a class="title" href="<?php echo $root_url; ?>"></a>
				</div>
			</header>
			<div class="content container">
				<nav class="perequation_level">
					<h2><?php echo $subtitle; ?></h2>
					<div class="pull-right"><a class="btn btn-large" href="<?php echo $root_url; ?>/comparer/regions">Comparer les collectivit&eacute;s</a></div>
					<div><a class="btn btn-small change_level" href="#"><i class="icon-chevron-left"></i> <span class="level_name">Previous Level</span></a></div>
					<div class="perequation btn-group" data-toggle="buttons-radio">
	          <a class="btn toutes <?php if ($perequation == 'toutes'){ echo 'active';} ?>" value="toutes" href="#">Toutes péréquations</a>
	          <a class="btn fpic <?php if ($perequation == 'fpic'){ echo 'active';} ?>" value="fpic" href="#">FPIC</a>
	          <a class="btn dmto <?php if ($perequation == 'dmto'){ echo 'active';} ?>" value="dmto" href="#">DMTO</a>
	        </div>
	      </nav>
	      <!--[if lt IE 9]>
		  		<p class="chromeframe">Votre navigateur est trop ancien et ne dispose pas des technologies n&#233;cessaires pour naviguer au sein de cette application.<br/>
		  		Vous pouvez <a href="http://www.google.com/chromeframe/?redirect=true">installer simplement Google Chrome Frame</a> pour am&#233;liorer votre exp&#233;rience (droits administrateur non requis).</p>
				<![endif]-->

				<div class="data">

				</div>
				<div class="legende">
					<ul>
						<li><div class="color receive"></div><span>B&#233;n&#233;ficiaires</span></li>
						<li><div class="color neutral"></div><span>Neutres</span></li>
						<li><div class="color give"></div><span>Contributeurs</span></li>
					</ul>
					<p>
						En cliquant sur le nom d'une collectivit&#233;, acc&#233;dez &#224; l'&#233;chelon inf&#233;rieur<br/>
						Au survol d'une bulle, faites appara&#238;tre la fiche du territoire
					</p>
				</div>
				<nav class="view_richesse clearfix">
						<div class="richesse clearfix">
							<div class="richesse_selector btn-group" data-toggle="buttons-radio">
								<button class="btn btn-small revenu <?php if ($richesse == 'revenu'){ echo 'active';} ?>" data-richesse="revenu">Revenu/hab.</button>
								<button class="btn btn-small potentiel <?php if ($richesse == 'potentiel'){ echo 'active';} ?>" data-richesse="potentiel">Potentiel fiscal</button>
							</div>
						</div>
						<div class="view clearfix">
							<div class="notices <?php echo $vue . ' ' . $niveau; ?>">
								<div class="notice richesse">
									L'axe ci-dessus dispose les collectivit&#233;s selon leur revenu par habitant<span class="departement"> ou leur potentiel fiscal</span>.<br/>
									La taille des bulles est proportionnelle au montant de la p&#233;r&#233;quation.
								</div>
							</div>
							<div class="view_selector" data-toggle="buttons-radio">
								<button class="btn btn-large donnees <?php if ($vue == 'donnees'){ echo 'active';} ?>" data-view="donnees">R&#233;partition par montant</button>
								<button class="btn btn-large richesse <?php if ($vue == 'richesse'){ echo 'active';} ?>" data-view="richesse">R&#233;partition selon les ressources</button>
							</div>
						</div>
				</nav>
			</div>
			<div id="unautorized" class="modal hide fade" tabindex="-1" role="dialog">
			  <div class="modal-header">
			    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
			    <h3 id="myModalLabel">R&#233;serv&#233; aux membres du Club Finances</h3>
			  </div>
			  <div class="modal-body">
			    <p>L'acc&#232;s aux donn&#233;es D&#233;partements et Intercommunalit&#233;s est r&#233;serv&#233; aux membres du Club Finances. Veuillez vous identifier ou cr&#233;er un compte.</p>
			  </div>
			  <div class="modal-footer">
			    <button class="rollback btn pull-left" data-dismiss="modal" aria-hidden="true">Fermer</button>
			    <button class="identify btn btn-primary">S'identifier</button>
			    <button class="identify btn btn-primary register">Devenir membre</button>
			  </div>
			</div>
			<footer class="main container">
				<a class="club-finance" href="http://www.lagazettedescommunes.com/rubriques/club-finances/" target="_blank"><img src="<?php echo $root_url; ?>/img/club_finance.jpg" alt="Club finance"/></a>
				<script>window.appUrl = "<?php echo $root_url; ?>";</script>
				{{ Asset::container('footer')->scripts() }}

		    <script>
				  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
				  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
				  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
				  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

				  ga('create', 'UA-40757740-1', 'angrykatze.com');
				  ga('send', 'pageview');
				</script>
			</footer>
		</div>
	</body>
</html>
