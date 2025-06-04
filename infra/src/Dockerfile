FROM public.ecr.aws/amazonlinux/amazonlinux:latest

# Install dependencies
RUN yum update -y && \
    yum install -y httpd && \
    yum search wget && \
    yum install wget -y && \
    yum install unzip -y

# Create working directory
WORKDIR /var/www/html

# Copy the website.zip file from the build context to the container
COPY . /var/www/html/


# Expose port 80 on the container
EXPOSE 80

# Set the default application that will start when the container starts
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]