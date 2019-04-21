#include <stdlib.h>
#include <glib.h>
#include <gtk/gtk.h>
#include <GL/gl.h>

static void destroy(GtkWidget* widget)
{
	gtk_main_quit();
}

static void setup(GtkGLArea *gl)
{
	gtk_gl_area_make_current(gl);
}

static gboolean render(GtkGLArea *gl, GdkGLContext *ctx)
{
	glBegin(GL_TRIANGLES);
	glColor3f(0.1, 0.2, 0.3);
	glVertex3f(0, 0, 0);
	glVertex3f(1, 0, 0);
	glVertex3f(0, 1, 0);
	glEnd();
	return TRUE;
}

int main(void) {
	/* skip one param, who needs it anyway */
	((void (*)(int *))gtk_init)(NULL);

	/* setup window */
	GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
	g_signal_connect(window, "destroy", G_CALLBACK(destroy), NULL);
	GtkWidget *gl = gtk_gl_area_new();
	gtk_container_add(GTK_CONTAINER(window), gl);
	g_signal_connect(gl, "realize", G_CALLBACK(setup), NULL);
	g_signal_connect(gl, "render", G_CALLBACK(render), NULL);

	/* show window */
	gtk_widget_show_all(window);
	gtk_window_fullscreen(window);
	gtk_main();

	exit(0);
}
