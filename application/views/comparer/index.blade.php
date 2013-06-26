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
		<div id="comparer">
			<header class="main clearfix">
				<div class="container">
					<a class="title" href="/"></a>
				</div>
			</header>

			<div class="content container">
				<a class="btn back" href="<?php echo $root_url; ?>/donnees/toutes/france">Retourner aux donn&#233;es</a>
				<div class="notice">Cet &#233;cran vous permet de comparer diff&#233;rentes collectivit&#233;s. Faites votre s&#233;lection parmi les choix suivants.</div>

				<div class="level <?php echo $niveau; ?>">
					<div class="niveau btn-group" data-toggle="buttons-radio">
	          <a class="btn regions <?php if ($niveau == 'regions'){ echo 'active';} ?>" data-level="regions" href="<?php echo $root_url; ?>/comparer/regions">Regions</a>
	          <a class="btn departements <?php if ($niveau == 'departements'){ echo 'active';} ?>" data-level="departements" href="<?php echo $root_url; ?>/comparer/departements">D&eacute;partements</a>
	          <a class="btn intercos <?php if ($niveau == 'intercos'){ echo 'active';} ?>" data-level="intercos" href="<?php echo $root_url; ?>/comparer/intercos">Intercommunalit&eacute;s</a>
	        </div>

		      <div class="row">
						<div class="collectivite collectivite1 span4" data-collectivite="1">
							<select class="interco_departements" data-collectivite="1"></select>
							<select class="choose" data-collectivite="1"></select>
							<div class="infos"></div>
						</div>
						<div class="collectivite collectivite2 span4" data-collectivite="2">
							<select class="interco_departements" data-collectivite="2"></select>
							<select class="choose" data-collectivite="2"></select>
							<div class="infos"></div>
						</div>
						<div class="collectivite collectivite3 span4" data-collectivite="3">
							<select class="interco_departements" data-collectivite="3"></select>
							<select class="choose" data-collectivite="3"></select>
							<div class="infos"></div>
						</div>
					</div>
				</div>
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
