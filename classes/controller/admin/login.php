<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Admin_Login extends Admincontroller {

	public function __construct()
	{
		parent::__construct();
	}

	public function action_index()
	{
		Session::instance();
		$this->xslt_stylesheet = 'admin/login';

		$user = User::instance();
		if
		(
			$user->logged_in() &&
			(
				$user->get_user_data('role') == 'admin' ||
				(
					is_array($user->get_user_data('role')) && in_array('admin', $user->get_user_data('role'))
				)
			)
		)
		{
			$this->redirect('/admin');
		}

		if (isset($_SESSION['modules']['pajas']['error']))
		{
			xml::to_XML(array('error' => $_SESSION['modules']['pajas']['error']), $this->xml_content);
			unset($_SESSION['modules']['pajas']['error']);
		}
	}

	public function action_do()
	{
		if (count($_POST))
		{
			Session::instance();
			$post = new Validate($_POST);
			$post->filter(TRUE, 'trim');
			$post->filter('username', 'strtolower');
			$post->rule('username', 'not_empty');
			$post->rule('password', 'not_empty');

			if ($post->check())
			{
				$user = new User(FALSE, $post['username'], $post['password']);

				if ($user->logged_in() && ($user->get_user_data('role')) && in_array('admin', $user->get_user_data('role')))
				{
	    		$this->redirect('/admin');
				}
				elseif (!$user->logged_in())
				{
					$_SESSION['modules']['pajas']['error'] = 'Wrong username or password';
				}
				elseif (!($user->get_user_data('role')) || !in_array('admin', $user->get_user_data('role')))
				{
					$_SESSION['modules']['pajas']['error'] = 'You are not authorized';
				}
				else
				{
					$_SESSION['modules']['pajas']['error'] = 'Unknown error';
				}
			}
		}
		$this->redirect();
	}

}