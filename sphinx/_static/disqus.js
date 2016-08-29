var disqus_shortname;
var disqus_identifier;
var disqus_language;
(function() {{
    var disqus_thread = $("#disqus_thread");
    disqus_shortname  = disqus_thread.data('disqus-shortname');
    disqus_identifier = disqus_thread.data('disqus-identifier');
    disqus_language   = disqus_thread.data('disqus-language');
    var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
    dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
}})();

/*
(function() {
    var d = document, s = d.createElement('script');
    s.src = '//tarantooldb.disqus.com/embed.js';
    s.setAttribute('data-timestamp', +new Date());
    (d.head || d.body).appendChild(s);
})();
*/
