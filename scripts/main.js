$(document).ready(function(){

	// pretty print the code snippets
	(function(){
		$('pre').addClass('prettyprint');
		prettyPrint();
	})();

	var $shareGooglePlus = $('#shareGooglePlus'),
		$shareTwitter = $('#shareTwitter'),
		$shareFacebook = $('#shareFacebook'),
		$shareBar = $('#shareBar');


	// rewrite the social sharer
	$shareBar.on('click','.icon', function(e){

		e.preventDefault();

		var share_service = e.currentTarget.className.split('icon-')[1];

		if(share_service === 'facebook') {
			window.open('https://www.facebook.com/sharer/sharer.php?u=' + location.href, 'sharer', 'width=626,height=436');

		} else if(share_service === 'twitter') {
		
			var tweetOptions = {
				'url' : location.href,
				'text' : '@subliminaltest, An understated approach to iOS integration testing. by @wear_here',
			}
			window.open('https://twitter.com/share?' + $.param(tweetOptions), '_blank');

		} else if(share_service === 'google-plus') {
			window.open('https://plus.google.com/share?url=' + location.href, '_blank', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
		}

		// return false;

	})

});