<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Admin_Themes extends Admincontroller {

	public function action_index()
	{
		// Set the name of the template to use
		$this->xslt_stylesheet = 'admin/themes';
	}

}
