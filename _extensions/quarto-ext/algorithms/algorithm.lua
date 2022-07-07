local needsPseudo = false
return {
  {
    CodeBlock = function(codeEl)
      if codeEl.attr.classes:includes('algorithm') then
        -- note that we need to include the dependency for pseudocode.js
        needsPseudo = true

        -- If this is LaTeX, read the contents of the 
        -- codeblock into a raw LaTeX block
        if quarto.doc.isFormat("latex") then
          quarto.doc.useLatexPackage("algorithm")
          --quarto.doc.useLatexPackage("algorithmicx")
          quarto.doc.useLatexPackage("algpseudocode")
          return pandoc.RawBlock("latex", codeEl.text)
        end
      end
    end,
    Meta = function(meta)
      if quarto.doc.isFormat("html") and needsPseudo then
        -- add the dependency
        quarto.doc.addHtmlDependency(
          {
            name = 'pseudocode',
            version = '0.1.0',
            scripts = {
              {
                name ='pseudocode.min.js',
                path = 'pseudocode.min.js'}
            },
            stylesheets = {
              {
                name = 'pseudocode.min.css',
                path = 'pseudocode.min.css'
              }
            }
          }
        )

        -- inject the rendering code
        local renderJS = "<script type='application/javascript'>const els = window.document.querySelectorAll('pre.algorithm');for (const el of els) {pseudocode.renderElement(el);}</script>"        
        if meta['include-after'] == nil then
            meta['include-after'] = {}
        end
        table.insert(meta['include-after'], pandoc.RawBlock("html", renderJS))

        -- we inject dummy math here just to ensure that the html 
        -- math package is loaded
        meta['dummy-math'] = pandoc.Math("InlineMath", "")
        
        return meta
      end
    end
  }
}