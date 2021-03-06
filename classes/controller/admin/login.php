<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Admin_Login extends Admincontroller {

	public function action_index()
	{
		Session::instance();
		$this->xslt_stylesheet = 'admin/login';
		$this->ignore_acl      = TRUE; // This page should be accessible by everyone

		$user = User::instance();
		if ($user->has_access_to(URL::base().'admin'))
			$this->redirect(URL::base().'admin');

		if (isset($_SESSION['modules']['pajas']['error']))
		{
			xml::to_XML(array('error' => $_SESSION['modules']['pajas']['error']), $this->xml_content);
			unset($_SESSION['modules']['pajas']['error']);
		}
	}

	public function action_do()
	{
		if (count($_POST) && isset($_POST['username']) && isset($_POST['password']))
		{
			Session::instance();

			$post = new Validation($_POST);
			$post->filter('trim');
			$post->filter('strtolower', 'username'); // Usename should always be lower case
			$post_values = $post->as_array();

			$user = new User(FALSE, $post_values['username'], $post_values['password']);

			if ($user->logged_in() && $user->has_access_to(URL::base().'admin'))
    		$this->redirect('admin');
			elseif ( ! $user->logged_in())
				$_SESSION['modules']['pajas']['error'] = 'Wrong username or password';
			elseif ( ! $user->has_access_to(URL::base().'admin'))
				$_SESSION['modules']['pajas']['error'] = 'You are not authorized';
			else
				$_SESSION['modules']['pajas']['error'] = 'Unknown error';
		}
		$this->redirect();
	}

}
