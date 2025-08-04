In an unlikely scenario that beautiful
<a href="http://shiny.rstudio.com/" target="_blank" rel="noopener">Shiny
</a>apps do not meet your analytical requirements and developing a
full-blown user interface. in [RGtk2](http://www.ggobi.org/rgtk2/) may
seem to be a little too much, there is a third, often overlooked
solution, - package
[svDialogs](https://cran.r-project.org/web/packages/svDialogs/index.html)
by Philippe Grosjean. The package in a convenient way enables user to
create various interface gadgets. For example the code:

    require(svDialogs)

    # Let's keep some data in one place
    user_figure <- svDialogs::dlg_input()

would result in the following window being presented to the user:

<figure>
<img
src="/post/2015-12-01-amusing-way-to-get-user-input-windows-in-r_files/untitled.png"
alt="Sample user input" />
<figcaption aria-hidden="true">Sample user input</figcaption>
</figure>

In this case the code will return the following object:

    str(user_figure)
    # Classes 'nativeGUI', 'textCLI', 'gui', 'environment' <environment: 0x11872b648> 
    user_figure
    # The default SciViews GUI (.GUI)
    # using widgets from: nativeGUI, textCLI
    # * Last call: dlg_input(gui = .GUI)
    # * Last widgets used: nativeGUI
    # * Last status: ok
    # * Last result:
    # [1] "100"

<em>The post was inspired by
<a href="http://stackoverflow.com/a/33934374/1655567" target="_blank" rel="noopener">an
amusing discussion</a> on SO.</em>
