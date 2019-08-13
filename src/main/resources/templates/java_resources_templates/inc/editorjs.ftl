<link rel="stylesheet" href="/js/simditor/styles/simditor.css" type="text/css">
<script type="text/javascript" src="/js/simditor/lib/module.js"></script>
<script type="text/javascript" src="/js/simditor/lib/uploader.js"></script>
<script type="text/javascript" src="/js/simditor/lib/hotkeys.js"></script>
<script type="text/javascript" src="/js/simditor/lib/dompurify.js"></script>
<script type="text/javascript" src="/js/simditor/lib/simditor.js"></script>

<script type="text/javascript">
    function init_editor(id) {
        new Simditor({
            textarea: $('#' + id),
            toolbar: [
                'title',
                'bold',
                'italic',
                'underline',
                'strikethrough',
                'fontScale',
                'color',
                'ol',
                'ul',
                'blockquote',
                'code',
                'table',
                'link',
                'image',
                'hr',
                'indent',
                'outdent',
                'alignment'
            ]
        });
    }
</script>