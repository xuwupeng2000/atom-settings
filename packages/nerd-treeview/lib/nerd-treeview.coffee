$ = jQuery = require 'jquery'

# influenced by https://github.com/customd/jquery-visible
visible = ($e, $tree) ->
    top = $e.offset().top
    bottom = top + $e.height()
    treeTop = $tree.offset().top
    treeBottom = treeTop + $tree.height()
    return top >= treeTop and bottom <= treeBottom

scrollIfInvisible = ($e, $tree) ->
    if not visible($e, $tree)
        $e[0]?.scrollIntoView($e.offset().top < $tree.offset().top)

toggleConfig = (keyPath) ->
    atom.config.set(keyPath, not atom.config.get(keyPath))

module.exports =
    num: 0

    openCallbacks: []

    activate: ->
        atom.commands.add('body', {
            'nerd-treeview:toggle': => @delegate('toggle')
            'nerd-treeview:reveal-active-file': =>
                @delegate('revealActiveFile')
            'nerd-treeview:toggle-focus': =>
                @delegate('toggleFocus')
        })
        atom.commands.add('.tree-view', {
            'nerd-treeview:open': => @open(true)
            'nerd-treeview:open-stay': => @open(false)
            'nerd-treeview:open-tab': => @openTab(true)
            'nerd-treeview:open-tab-stay': => @openTab(false)

            'nerd-treeview:add-tab': => @addTab(true)
            'nerd-treeview:add-tab-stay': => @addTab(false)

            'nerd-treeview:open-split-vertical': => @splitVertical(true)
            'nerd-treeview:open-split-vertical-stay': => @splitVertical(false)
            'nerd-treeview:open-split-horizontal': => @splitHorizontal(true)
            'nerd-treeview:open-split-horizontal-stay': =>
                @splitHorizontal(false)

            'nerd-treeview:expand': => @expand(true)

            'nerd-treeview:close-parent': => @closeParent()
            'nerd-treeview:close-children': => @closeChildren()

            'nerd-treeview:open-tree': => @openTree(true)
            'nerd-treeview:open-tree-stay': => @openTree(false)

            'nerd-treeview:jump-up': => @jumpUp()
            'nerd-treeview:jump-down': => @jumpDown()
            'nerd-treeview:jump-root': => @jumpRoot()
            'nerd-treeview:jump-parent': => @jumpParent()
            'nerd-treeview:jump-first': => @jumpFirst()
            'nerd-treeview:jump-last': => @jumpLast()
            'nerd-treeview:jump-next': => @jumpNext()
            'nerd-treeview:jump-prev': => @jumpPrev()
            'nerd-treeview:jump-top': => @jumpLine(1)
            'nerd-treeview:jump-line': => @jumpLine()

            'nerd-treeview:change-root': => @changeRoot(false, false)
            'nerd-treeview:change-root-save-state': => @changeRoot(false, true)
            'nerd-treeview:up': => @changeRoot(true, false)
            'nerd-treeview:up-save-state': => @changeRoot(true, true)

            'nerd-treeview:toggle-ignored-names':
                -> toggleConfig 'tree-view.hideIgnoredNames'
            'nerd-treeview:toggle-vcs-ignored-files':
                -> toggleConfig 'tree-view.hideVcsIgnoredFiles'
            'nerd-treeview:toggle-files': => @toggleFiles()

            'nerd-treeview:add-file': => @delegate('add', true)
            'nerd-treeview:add-folder': => @delegate('add')
            'nerd-treeview:copy-full-path':
                => @delegate('copySelectedEntryPath')
            'nerd-treeview:remove': => @remove()
            'nerd-treeview:copy-name': => @copyName(false)
            'nerd-treeview:copy-name-ext': => @copyName(true)

            'nerd-treeview:move': => @delegate('moveSelectedEntry')
            'nerd-treeview:paste': => @delegate('pasteEntries')
            'nerd-treeview:duplicate': => @delegate('copySelectedEntry')
            'nerd-treeview:copy': => @delegate('copySelectedEntries')
            'nerd-treeview:cut': => @delegate('cutSelectedEntries')

            'nerd-treeview:scroll-up': => @scroll(false)
            'nerd-treeview:scroll-down': => @scroll(true)
            'nerd-treeview:scroll-half-screen-up': =>
                @scrollScreen(false, false)
            'nerd-treeview:scroll-half-screen-down': =>
                @scrollScreen(true, false)
            'nerd-treeview:scroll-full-screen-up': =>
                @scrollScreen(false, true)
            'nerd-treeview:scroll-full-screen-down': =>
                @scrollScreen(true, true)

            'nerd-treeview:scroll-cursor-to-top': => @cursor(true)
            'nerd-treeview:scroll-cursor-to-middle': => @centreCursor()
            'nerd-treeview:scroll-cursor-to-bottom': => @cursor(false)

            'nerd-treeview:move-to-top-of-screen': => @move('top')
            'nerd-treeview:move-to-middle-of-screen': => @move('middle')
            'nerd-treeview:move-to-bottom-of-screen': => @move('bottom')

            'nerd-treeview:repeat-prefix': (e) => @prefix(e)
            'nerd-treeview:clear-prefix': => @clearPrefix()
        })

        atom.workspace.onDidOpen (e) =>
            callback(e) for callback in @openCallbacks
            @openCallbacks = []

    getTreeView: ->
        treeView = atom.packages.getActivePackage('tree-view')
        treeView = treeView?.mainModule.treeView

        root = $('.project-root')[0]
        if treeView and root and not treeView.selectedEntry()
            treeView.selectEntry(root)

        return treeView

    clearPrefix: ->
        @num = 0

    delegate: (method, arg) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        treeView[method](arg)

    open: (activate) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        activePane = atom.workspace.getActivePane()

        selected = treeView.selectedEntry()
        if not $(selected).is('.file')
            return treeView.openSelectedEntry(activate)

        item = activePane.getActiveItem()
        replace = item and !item.isModified?()

        same = false
        for paneItem in activePane.getItems()
            if (selected.getPath() == paneItem.getPath?())
                same = true
                break

        if not (item and same)
            if replace
                treeView.openSelectedEntry(activate)
                @openCallbacks.push -> activePane.destroyItem(item)
            else treeView.openSelectedEntryDown(activate)
        else treeView.openSelectedEntry(activate)

    openTab: (activate) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        treeView.openSelectedEntry(activate)

    addTab: (activate) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        treeView.openSelectedEntry(activate)

        activePane = atom.workspace.getActivePane()
        item = activePane.getActiveItem()
        if item
            selected = treeView.selectedEntry()
            @openCallbacks.push ->
                activePane.activateItem(item)
                treeView.selectEntry(selected)

    splitVertical: (activate) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        treeView.openSelectedEntryDown(activate)
        @openCallbacks.push -> treeView.show() unless activate

    splitHorizontal: (activate) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        treeView.openSelectedEntryRight(activate)
        @openCallbacks.push -> treeView.show() unless activate

    expand: (recursive) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        treeView.expandDirectory(recursive)

    closeParent: ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        selected = treeView.selectedEntry()
        directory = $(selected).parents('.directory')[0]
        if directory
            directory.collapse()
            treeView.selectEntry(directory)

    closeChildren: ->
        @clearPrefix()

        return if not treeView = @getTreeView()

        selected = treeView.selectedEntry()
        directories = $(selected).find('>ol>li.directory')
        directory.collapse(true) for directory in directories

    openTree: (activate, path) ->
        @clearPrefix()

        return if not treeView = @getTreeView()

        if not path
            selected = treeView.selectedEntry()
            if $(selected).is('.directory')
                path = selected.getPath()

        if path
            atom.project.addPath(path)

            treeView.selectEntry($('.project-root').last()[0]) if activate

    jump: (getNode) ->
        return if not treeView = @getTreeView()

        selected = treeView.selectedEntry()
        node = getNode(selected)[0]
        if node
            treeView.selectEntry(node)
            scrollIfInvisible($(node).find('.name').eq(0), treeView)

    getNextEntry: (selected) ->
        node = $(selected)
        if node.is('.directory.expanded') and node.find('li:visible').size()
            li = node.find('li:visible')
            node = li.first() if li.size()
        else
            while node.size() and not node.next(':visible').size()
                node = node.parents('.directory:visible').eq(0)
            node = node.next(':visible') if node.size()
        return node

    getPrevEntry: (selected) ->
        node = $(selected).prev(':visible')
        if not node.size()
            node = $(selected).parents('.directory:visible').eq(0)
        else if node.is('.directory.expanded')
            li = node.find('li:visible')
            node = li.last() if li.size()
        return node

    repeatJump: (selected, getNode) ->
        oldSelection = $('#non-existing-id')
        for _ in [0..Math.max(@num - 1, 0)]
            selected = getNode(selected)
            break unless selected.size()
            oldSelection = selected

        @clearPrefix()
        return oldSelection

    jumpUp: ->
        @jump (selected) => @repeatJump(selected, @getPrevEntry)

    jumpDown: ->
        @jump (selected) => @repeatJump(selected, @getNextEntry)

    jumpRoot: ->
        @jump (selected) -> $(selected).parents('.project-root:visible')

    jumpParent: ->
        @jump (selected) =>
            @repeatJump(selected, (selected) ->
                $(selected).parents('.directory:visible')
            )

    jumpFirst: ->
        @jump (selected) -> $(selected).parent().children('li:visible').first()

    jumpLast: ->
        @jump (selected) -> $(selected).parent().children('li:visible').last()

    jumpNext: ->
        @jump (selected) => @repeatJump(selected, (selected) ->
            $(selected).next(':visible')
        )

    jumpPrev: ->
        @jump (selected) => @repeatJump(selected, (selected) ->
            $(selected).prev(':visible')
        )

    jumpLine: (num) ->
        return if not treeView = @getTreeView()
        $elements = treeView.find('li:visible')

        if not num
            num = if @num then @num else $elements.size()
            num = $elements.size() if num > $elements.size()

        $entry = $elements.eq(num - 1)
        treeView.selectEntry($entry[0])
        scrollIfInvisible($entry, treeView)

        @clearPrefix()

    moveInArray: (array, i) ->
        array.splice(i, 0, array.splice(array.length - 1, 1)[0])

    rootIndex: (path, rootDirectories) ->
        for directory, i in rootDirectories
            if directory.getPath() == path
                return i
        return null

    fixState: (treeView, up, root, selected, index) ->
        if up
            (entries = {})[root.directory.name] = root.directory.expansionState
            state =
                isExpanded: true, entries: entries
            selection = $("span[data-path='#{selected.directory.path}]")
                .closest('li')[0]
            console.log(selected.directory)
        else
            selection = $('.project-root')[index]
            state = selected.directory.expansionState

        (expansionState = {})[treeView.roots[index].getPath()] = state
        console.log(selection, state, expansionState)
        treeView.updateRoots(expansionState)
        treeView.selectEntry(selection)

    changeRoot: (up, state) ->
        @clearPrefix()

        return if not treeView = @getTreeView()

        selected = treeView.selectedEntry()
        $selected = $(selected)
        if not $selected.is('.directory')
            selected = $selected.parents('.directory')[0]

        rootDirectories = atom.project.getDirectories()
        root = $selected.closest('.project-root')[0]
        index = @rootIndex(root.getPath(), rootDirectories)

        path = false
        path = rootDirectories[index].getParent().getPath() if up
        return if path == root.getPath()

        @openTree(false, path)
        @moveInArray(atom.project.rootDirectories, index)
        @moveInArray(atom.project.repositories, index)
        atom.project.removePath(root.getPath())

        @fixState(treeView, up, root, selected, index) if state

    toggleFiles: ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        $(treeView).toggleClass('hide-files')

    remove: ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        selected = treeView.selectedEntry()

        if $(selected).is('.project-root')
            treeView.removeProjectFolder(
                target: $(selected).find('.header .name')
            )
        else treeView.removeSelectedEntries()

    copyName: (ext) ->
        @clearPrefix()

        return if not treeView = @getTreeView()

        selected = treeView.selectedEntry()
        name = $(selected).find('.name').first().data('name')
        name = name.replace(/\.[^\.]+$/, '') unless ext or /^\./.test(name)
        atom.clipboard.write(name)

    scroll: (down) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        selected = treeView.selectedEntry()

        if down
            treeView.scrollDown()
            while not visible($(selected), treeView)
                selected = @getNextEntry(selected)[0]
            treeView.selectEntry(selected)
        else
            treeView.scrollUp()
            while not visible($(selected), treeView)
                selected = @getPrevEntry(selected)[0]
            treeView.selectEntry(selected)

    scrollScreen: (down, full) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        $selected = $(treeView.selectedEntry())

        D = if full then 1 else 2
        centre = parseInt((treeView.offset().left + treeView.width()) / 2)
        scrollY = parseInt((treeView.offset().top + treeView.height()) / D)
        curY = $selected.offset().top

        curScroll = treeView.scrollTop()
        treeView.scrollTop(curScroll + if down then scrollY else -scrollY)

        $element = $(document.elementFromPoint(centre, curY))
            .closest('li:visible')
        $element = treeView.find('li:visible').last() unless $element.size()

        treeView.selectEntry($element[0])
        $entry = $element.find('.name').eq(0)
        scrollIfInvisible($entry, treeView)

    cursor: (up) ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        $selected = $(treeView.selectedEntry()).find('.name').eq(0)

        top = $selected.offset().top
        treeTop = treeView.offset().top

        target = if up then treeTop else treeTop + treeView.height()
        source = if up then top else top + $selected.height()

        curScroll = treeView.scrollTop()
        treeView.scrollTop(curScroll + source - target)

    centreCursor: ->
        @clearPrefix()

        return if not treeView = @getTreeView()
        $selected = $(treeView.selectedEntry()).find('.name').eq(0)

        middle = parseInt($selected.offset().top + $selected.height() / 2)
        treeMiddle = parseInt(treeView.offset().top + treeView.height() / 2)

        curScroll = treeView.scrollTop()
        treeView.scrollTop(curScroll + middle - treeMiddle)

    move: (where) ->
        @clearPrefix()

        return if not treeView = @getTreeView()

        centre = parseInt((treeView.offset().left + treeView.width()) / 2)
        if where is 'top'
            point = treeView.offset().top + 16
        else if where is 'middle'
            point = parseInt(treeView.offset().top + treeView.height() / 2)
        else
            point = treeView.height() - treeView.offset().top - 16

        $e = $(document.elementFromPoint(centre, point))
            .closest('li:visible')

        if not $e.size()
            $e = treeView.find('li:visible')
            $e = if where is 'top' then $e.first() else $e.last()

        treeView.selectEntry($e[0]) if $e.size()

    prefix: (e) ->
        keyboardEvent = e.originalEvent?.originalEvent ? e.originalEvent
        num = parseInt(atom.keymaps.keystrokeForKeyboardEvent(keyboardEvent))
        @num = @num * 10 + num

        # TODO: temp fix to prevent freeze, ideally each function should handle
        @num = 9999 if @num > 9999
