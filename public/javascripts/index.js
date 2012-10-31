jQuery.noConflict();

jQuery(document).ready(function($) {

  // Newsletter
  $('form').submit(function() {
    var fname = $('#fname').val();
    var lname = $('#lname').val();
    var email = $('#email').val();

    var data = 'email='+ email+'&fname='+fname+'&lname='+lname;

    var pattern = new RegExp(/^[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$/);
    if(pattern.test(email)) {
      $.ajax({
        type: "POST",
        url: "/newsletter",
        data: data,
        success: function() {
            $('#newsletter').remove();
            $('.social-media').before('<p>Email added, thanks! Now you can check out the links below!</p>');
            mixpanel_events.add_email(email);
        }
      });
    }

    return false;
  });

  var mixpanel_events = {
    add_email: function(email){
      mixpanel.people.set({ $email: email,
                            $created: new Date().toDateString() });
      mixpanel.identify(email);
      mixpanel.name_tag(email);
      mixpanel.track("Email added");
    },

    facebook: function(){
      mixpanel.track_links(".social-media a.facebook", "facebook");
    },

    tumblr: function(){
        mixpanel.track_links(".social-media a.tumblr", "blog");
    },

    //twitter: function(){
      //mixpanel.track_links(".social-media a.twitter", "twitter");
    //},



    coming_from: function(){
      mixpanel.register({ 'referrer': document.referrer });
    },

    init: function(){
	  mixpanel_events.tumblr();
      mixpanel_events.facebook();
      //mixpanel_events.twitter();
      mixpanel_events.coming_from();
    }
  };

  mixpanel_events.init();
});
