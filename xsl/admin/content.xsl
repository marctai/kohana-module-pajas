<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="tpl.default.xsl" />

	<xsl:template name="tabs">
		<ul class="tabs">
			<li>
				<a href="content">
					<xsl:if test="/root/meta/action = 'index'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>List content</xsl:text>
				</a>
			</li>
			<li>
				<a href="content/add_content">
					<xsl:if test="/root/meta/action = 'add_content'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>Add content</xsl:text>
				</a>
			</li>
		</ul>
	</xsl:template>


  <xsl:template match="/">
  	<xsl:if test="/root/meta/action = 'index'">
  		<xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Content'" />
		  	<xsl:with-param name="h1" select="'List content'" />
  		</xsl:call-template>
  	</xsl:if>
  	<xsl:if test="/root/meta/action = 'add_content'">
  		<xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Content'" />
		  	<xsl:with-param name="h1" select="'Add content'" />
  		</xsl:call-template>
  	</xsl:if>
  	<xsl:if test="/root/meta/action = 'edit_content'">
  		<xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Content'" />
		  	<xsl:with-param name="h1" select="'Edit content'" />
  		</xsl:call-template>
  	</xsl:if>
  </xsl:template>

	<!-- List content -->
  <xsl:template match="content[../meta/controller = 'content' and ../meta/action = 'index']">
  	<form method="get">
  		<label for="content_type">
  			Content Type:
  			<select name="content_type">
  				<xsl:for-each select="types/type">
  					<xsl:sort select="name" />
  					<option value="{@id}">
  						<xsl:if test="/root/meta/url_params/content_type = @id">
  							<xsl:attribute name="selected">selected</xsl:attribute>
  						</xsl:if>
  						<xsl:value-of select="name" />
  					</option>
  				</xsl:for-each>
  			</select>
  		</label>

			<xsl:call-template name="form_button">
				<xsl:with-param name="value" select="'Show contents'" />
			</xsl:call-template>
  	</form>

		<table>
			<thead>
				<tr>
					<th class="medium_row">Content ID</th>
					<th>Content</th>
					<th class="medium_row">Action</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="contents/content">
					<tr>
						<xsl:if test="position() mod 2 = 1">
							<xsl:attribute name="class">odd</xsl:attribute>
						</xsl:if>
						<td><xsl:value-of select="@id" /></td>
						<td><xsl:value-of select="concat(substring(content,1,60), '...')" /></td>
						<td>
							[<a>
							<xsl:attribute name="href">
								<xsl:text>content/edit_content/</xsl:text>
								<xsl:value-of select="@id" />
							</xsl:attribute>
							<xsl:text>Edit</xsl:text>
							</a>]
							[<a>
							<xsl:attribute name="href">
								<xsl:text>content/rm_content/</xsl:text>
								<xsl:value-of select="@id" />
							</xsl:attribute>
							<xsl:text>Delete</xsl:text>
							</a>]
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
  </xsl:template>

	<!-- Add content -->
  <xsl:template match="content[../meta/controller = 'content' and ../meta/action = 'add_content']">
  	<form method="post" action="content/add_content">

			<h2>Content types</h2>

			<xsl:for-each select="types/type">
				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="concat('type_id_',@id)" />
					<xsl:with-param name="label" select="concat(name,':')" />
					<xsl:with-param name="type" select="'checkbox'" />
				</xsl:call-template>
			</xsl:for-each>

			<h2>Content</h2>
			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'content'" />
				<xsl:with-param name="label" select="'Content:'" />
				<xsl:with-param name="type" select="'textarea'" />
				<xsl:with-param name="rows" select="'20'" />
			</xsl:call-template>

			<xsl:call-template name="form_button">
				<xsl:with-param name="value" select="'Add content'" />
			</xsl:call-template>
  	</form>
  </xsl:template>

	<!-- Edit content -->
  <xsl:template match="content[../meta/controller = 'content' and ../meta/action = 'edit_content']">
  	<form method="post" action="content/edit_content/{content_id}">

			<h2>Content types</h2>

			<xsl:for-each select="types/type">
				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="concat('type_id_',@id)" />
					<xsl:with-param name="label" select="concat(name,':')" />
					<xsl:with-param name="type" select="'checkbox'" />
				</xsl:call-template>
			</xsl:for-each>

			<h2>Content</h2>
			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'content'" />
				<xsl:with-param name="label" select="'Content:'" />
				<xsl:with-param name="type" select="'textarea'" />
				<xsl:with-param name="rows" select="'20'" />
			</xsl:call-template>

			<xsl:call-template name="form_button">
				<xsl:with-param name="value" select="'Save'" />
			</xsl:call-template>
  	</form>
  </xsl:template>

</xsl:stylesheet>
